require 'optparse'
require 'ostruct'
require 'syslog'
require 'everpager/pagerduty'
require 'everpager/version'
require 'everpager/about'
require 'awesome_print'

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

    def initialize(arguments)
      @arguments = arguments
      @whoami = File.basename($PROGRAM_NAME).to_sym

      @global_options = { :debug => false, :help => false }
      @action = nil

      @details = {}

    end

    def run
       begin
         parsed_options?
         arguments_valid?
         options_valid?
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

      opts = OptionParser.new

      case @whoami
        when :notify_pagerduty then opts.banner = "Usage: #{ID} [options] <description>"
        else opts.banner = "Usage: #{ID} [options] <action> <description>"
      end
      case @whoami
        when :notify_pagerduty then opts.separator ""
        else
          opts.separator ""
          opts.separator "Actions:"
          opts.separator "    trigger                          Trigger Pagerduty incident"
          opts.separator "    acknowledge                      Acknowledge a Pagerduty incident"
          opts.separator "    resolve                          Resolve a Pagerduty indicent"
          opts.separator ""
      end
      opts.separator "Common options:"
      opts.on('-K', '--service-key KEY',      String,      "Pagerduty service key (required)")                                { |key|       @global_options[:pd_service_key] = key }
      opts.on('-u', '--username USERNAME',    String,      "Pagerduty account username")                                      { |username|  @global_options[:username] = username }
      opts.on('-p', '--password PASSWORD',    String,      "Pagerduty account password")                                      { |password|  @global_options[:password] = password }
      opts.separator ""
      opts.separator "Trigger options:"
      opts.on('-H', '--hostname HOSTNAME',    String,      "Hostname (required)")                                             { |hostname|  @global_options[:hostname] = hostname }
      opts.on('-A', '--hostalias ALIAS',      String,      "Host alias (required)")                                           { |hostalias| @global_options[:hostalias] = hostalias }
      opts.on('-I', '--IP-address IPADDRESS', String,      "Host IP address (required)")                                      { |ipaddress| @global_options[:ipaddress] = ipaddress }
      opts.on('-S', '--service SVC_DESCR',    String,      "Service description (required for service notifications)")        { |svc_descr| @global_options[:svc_descr] = svc_descr }
      opts.on('-s', '--status STATUS',        String,      "Service/Host status (#{statuses.join(',')})")                     { |status|    @global_options[:status] = status.downcase.to_sym }
      opts.on('-N', '--notification-type TYPE', String,    "Notification Type (#{notification_types.join(',')}) (required)")  { |type|      @global_options[:notification_type] = type.downcase.to_sym }
      opts.separator("                                       problem        -> trigger")
      opts.separator("                                       recovery       -> resolve")
      opts.separator("                                       acknowledgment -> acknowledge")
      opts.separator ""
      opts.separator "General options:"
      opts.on('-d', '--debug',                             "Enable debug mode")                                               { @global_options[:debug] = true}
      opts.on('-a', '--about',                             "Display #{ID} information")                                       { output_message ABOUT, 0 }
      opts.on('-V', '--version',                           "Display #{ID} version")                                           { output_message VERSION, 0 }
      opts.on_tail('--help',                               "Show this message")                                               { @global_options[:HELP] = true }

      opts.order!(@arguments)
      output_message opts, 0 if @arguments.size == 0 or @global_options[:HELP]

      case @whoami
        when :notify_pagerduty
          case @global_options[:notification_type]
            when :problem then @action = :trigger
            when :recovery then @action = :resolve
            when :acknowledgement then @action = :acknowledge
            else raise OptionParser::InvalidArgument, "invalid notification type #{@global_options[:notification_type]}"
          end
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

    def arguments_valid?
    end

    def process_options
      [ :hostname, :ipaddress, :hostalias, :svc_descr, :status].each do |s|
        @details[s] = @global_options[s] unless @global_options[s].nil?
      end
    end

    def process_arguments
      @global_options[:svc_output] = @arguments.join(' ')
    end

    def process_command
      case @action
        when :trigger,:acknowledge,:resolve
          ap @global_options if @global_options[:debug]
          ap @details if @global_options[:debug]

          description = "#{@global_options[:hostalias]}: #{@global_options[:svc_descr]}: #{@global_options[:svc_output]}"
          incident_key = "#{@global_options[:svc_descr]}@#{@global_options[:hostalias]}"

          p = Incident.new(@global_options[:pd_service_key],incident_key)
          case @global_options[:notification_type]
            when :problem then p.trigger(description,@details)
            when :acknowledgement then p.acknowledge(description,@details)
            when :recovery then p.resolve(description,@details)
          end
          syslog_message = "#{@global_options[:notification_type]} #{@global_options[:hostalias]}: #{@global_options[:svc_descr]}: #{p.state} #{p.incident_key}"
          Syslog.open(ID.to_s, Syslog::LOG_PID, Syslog::LOG_DAEMON) { |s| s.info syslog_message }
          ap p if @global_options[:debug]
        when :list
          incidents = IncidentSet.new(@global_options[:username],@global_options[:password])
          ap incidents
      end

    end

    def output_message(message, exitstatus=nil)
      m = (! exitstatus.nil? and exitstatus > 0) ? "%s: error: %s" % [ID, message] : message
      $stderr.write "#{m}\n" if STDIN.tty?
      exit exitstatus unless exitstatus.nil?
    end

  end

end