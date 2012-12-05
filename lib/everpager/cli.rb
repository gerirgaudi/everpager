require 'optparse'
require 'ostruct'
require 'syslog'
require 'inifile'
require 'everpager/pagerduty'
require 'everpager/version'
require 'everpager/about'

module Everpager

  class CLI

    include Pagerduty

    STATUS = {
        :ok               =>  OpenStruct.new({ :num => 0, :str => "OK" }),
        :warning          =>  OpenStruct.new({ :num => 1, :str => "WARNING"}),
        :critical         =>  OpenStruct.new({ :num => 2, :str => "CRITICAL"}),
        :unknown          =>  OpenStruct.new({ :num => 3, :str => "UNKNOWN"})
    }

    NOTIFICATION_TYPE = {
        :problem          => OpenStruct.new({ :num => 0, :str => "PROBLEM" }),
        :recovery         => OpenStruct.new({ :num => 1, :str => "RECOVERY"}),
        :acknowledgement  => OpenStruct.new({ :num => 2, :str => "ACKNOWLEDGEMENT"})
    }

    APPLICATION_CONTEXTS = [ :shell, :nagios, :splunk ]

    DEFAULT_APP_CONF = 'etc/apps/everpager/default/app.conf'

    def initialize(arguments)
      @arguments = arguments
      @whoami = File.basename($PROGRAM_NAME).to_sym
      @global_options = { :debug => false, :help => false, :context => nil, :appconf => DEFAULT_APP_CONF, :config => nil }
      @global_options[:appconf] = ENV['SPLUNK_HOME'] + '/' +  DEFAULT_APP_CONF if ENV['SPLUNK_HOME']
      @action = nil

      case ID
        when :everpager, :splunk_alert_pagerduty  then @global_options[:context] = :shell
        when :notify_pagerduty                    then @global_options[:context] = :nagios
        else
          if ID.to_s.start_with?('splunk_alert_pagerduty_')
            @global_options[:context] = :splunk
            @global_options[:key] = ID.to_s.gsub(/^splunk_alert_pagerduty_/,'')
          else
            @global_options[:context] = nil
            @global_options[:key] = nil
          end
      end

      @details = {}

    end

    def run
       begin
         parsed_options?
         options_valid?
         loaded_config?
         config_valid?
         arguments_valid?
         process_options
         process_arguments
         process_command
       rescue => e
         if @global_options[:debug]
           output_message "#{e.message} #{e.class}\n  #{e.backtrace.join("\n  ")}",3
         else
           output_message e.message, 1
         end
       end
     end

     protected

    def parsed_options?

      statuses = STATUS.keys
      notification_types = NOTIFICATION_TYPE.keys
      contexts = APPLICATION_CONTEXTS

      opts = OptionParser.new

      case @global_options[:context]
        when :shell   then opts.banner = "Usage: #{ID} [options] <action> <description>"
        when :nagios  then opts.banner = "Usage: #{ID} [options] <description>"
        when :splunk  then opts.banner = "Usage: #{ID} [options] <description>"
        else opts.banner = "Usage: #{ID} [options] <action> <description>"
      end
      case @global_options[:context]
        when :shell
          opts.separator ""
          opts.separator "Actions:"
          opts.separator "    trigger                          Trigger Pagerduty incident"
          opts.separator "    acknowledge                      Acknowledge a Pagerduty incident"
          opts.separator "    resolve                          Resolve a Pagerduty indicent"
          opts.separator "    list                             List Pagerduty incidents"
          opts.separator ""
        else
          opts.separator ""
      end
      unless @global_options[:context] == :splunk
        opts.separator "Common options:"
        opts.on('-K', '--service-key KEY',              String,  "Pagerduty service key (required)")                                { |o| @global_options[:pd_service_key] =  o }

        opts.on('-u', '--username USERNAME',            String,  "Pagerduty account username (for list)")                           { |o| @global_options[:username] =        o }
        opts.on('-p', '--password PASSWORD',            String,  "Pagerduty account password (for list)")                           { |o| @global_options[:password] =        o }
        opts.on('-C', '--context CONTEXT',              String,  "Application context (#{contexts.join(',')})")                     { |o| @global_options[:context] =         o.to_sym } if @global_options[:context] == :shell
        opts.on('-c', '--appconf CONFIG',               String,  "Pagerduty API keys")                                              { |o| @global_options[:appconf] =         o }
        opts.on('-k', '--key KEY',                      String,  "Key")                                                             { |o| @global_options[:key] =             o }
      end
      if [:shell,:nagios].include?(@global_options[:context])
        opts.separator ""
        opts.separator "Trigger options:"
        opts.on('-H', '--hostname HOSTNAME',            String,  "Hostname (required)")                                             { |o| @global_options[:hostname] =        o }
        opts.on('-a', '--hostalias ALIAS',              String,  "Host alias (required)")                                           { |o| @global_options[:hostalias] =       o }
        opts.on('-I', '--IP-address IPADDRESS',         String,  "Host IP address (required)")                                      { |o| @global_options[:ipaddress] =       o }
        opts.on('-S', '--service SVC_DESCR',            String,  "Service description (required for service notifications)")        { |o| @global_options[:svc_descr] =       o }
        opts.on('-s', '--status STATUS',                String,  "Service/Host status (#{statuses.join(',')})")                     { |o| @global_options[:status] =          o.downcase.to_sym }
      end
      if [:shell,:nagios].include?(@global_options[:context])
        opts.on('-N', '--notification-type TYPE',       String,  "Notification Type (#{notification_types.join(',')}) (required)")  { |o| @global_options[:notification_type] = o.downcase.to_sym }
        opts.separator("                                       problem        -> trigger")
       opts.separator("                                       recovery       -> resolve")
        opts.separator("                                       acknowledgment -> acknowledge")
      end
      opts.separator ""
      opts.separator "General options:"
      opts.on('-D', '--debug',                             "Enable debug mode")                                               { @global_options[:debug] = true}
      opts.on('-A', '--about',                             "Display #{ID} information")                                       { output_message ABOUT, 0 }
      opts.on('-V', '--version',                           "Display #{ID} version")                                           { output_message VERSION, 0 }
      opts.on_tail('--help',                               "Show this message")                                               { @global_options[:HELP] = true }

      opts.order!(@arguments)
      output_message opts, 0 if @arguments.size == 0 or @global_options[:HELP]

      case @global_options[:context]
        when :nagios
          case @global_options[:notification_type]
            when :problem then @action = :trigger
            when :recovery then @action = :resolve
            when :acknowledgement then @action = :acknowledge
            else raise OptionParser::InvalidArgument, "invalid notification type #{@global_options[:notification_type]}"
          end
        when :splunk
          @global_options[:notification_type] = :problem
          @action = :trigger
        else
          @action = @arguments.shift.to_sym
      end
      raise OptionParser::InvalidArgument, "invalid action #@action" unless [:trigger,:acknowledge,:resolve,:list].include?(@action)
    end

    def options_valid?
#      [ :pd_service_key, :problemid, :hostname, :ipaddress, :hostalias, :svc_descr, :status, :notification_type].each do |s|
#        raise OptionParser::MissingArgument, "missing #{s} option" if @global_options[s].nil?
#      end
    end

    def loaded_config?
      @global_options[:config] = IniFile.load(@global_options[:appconf]) if File.exist?(@global_options[:appconf])
    end

    def config_valid?

    end

    def arguments_valid?
    end

    def process_options
      case @global_options[:context]
        when :nagios
          [ :hostname, :ipaddress, :hostalias, :svc_descr, :status].each do |s|
            @details[s] = @global_options[s] unless @global_options[s].nil?
          end
        when :splunk
          if @global_options[:key].nil?
            key = ID.to_s.gsub(/^splunk_alert_pagerduty_/,'')
          else
            key = @global_options[:key]
          end
          @global_options[:pd_service_key] = @global_options[:config][key]['service_key'] unless key.nil?
      end
    end

    def process_arguments
      case @global_options[:context]
        when :nagios
          @global_options[:svc_output] = @arguments.join(' ')
        when :splunk
          @global_options[:svc_descr] = ARGV[3]
          @global_options[:svc_output] = ARGV[0] + ' events'
      end
    end

    def process_command
      description = "invalid description"
      incident_key = nil

      case @global_options[:context]
        when :nagios
          case @action
            when :trigger,:acknowledge,:resolve
              description = "#{@global_options[:hostalias]}: #{@global_options[:svc_descr]}: #{@global_options[:svc_output]}"
              incident_key = "#{@global_options[:svc_descr]}@#{@global_options[:hostalias]}"
            else
              puts "invalid action"
          end
        when :splunk
          case @action
            when :trigger
              incident_key = "#{@global_options[:svc_descr]}".gsub(/::/,'/').gsub(/\s+/,'')
              description = "#{incident_key}: #{@global_options[:svc_output]}"
            else
              puts "invalid action"
          end
      end
      p = Incident.new(@global_options[:pd_service_key],incident_key)
      case @global_options[:notification_type]
        when :problem then p.trigger(description,@details)
        when :acknowledgement then p.acknowledge(description,@details)
        when :recovery then p.resolve(description,@details)
      end
      syslog_message = "#{@global_options[:notification_type]} #{@global_options[:hostalias]}: #{@global_options[:svc_descr]}: #{p.state} #{p.incident_key}"
      Syslog.open(ID.to_s, Syslog::LOG_PID, Syslog::LOG_DAEMON) { |s| s.info syslog_message }
    end

    def output_message(message, exitstatus=nil)
      m = (! exitstatus.nil? and exitstatus > 0) ? "%s: error: %s" % [ID, message] : message
      $stderr.write "#{m}\n" if STDIN.tty?
      exit exitstatus unless exitstatus.nil?
    end

  end

end