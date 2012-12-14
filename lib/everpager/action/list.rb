require 'time'
require 'everpager/pagerduty'

module Everpager; module Action

  class List

    include Everpager::PagerDuty

    COMPONENTS = [ :incidents, :alerts, :users, :log_entries, :schedules, :services ]

    def initialize(arguments,options)

      @arguments = arguments
      @options = options
      @params = {}
      @component = @arguments.shift.to_sym unless @arguments.empty?
      raise StandardError, "invalid component #@component" unless COMPONENTS.include?(@component)

      api_params = case @component
                      when :incidents then Incidents.api_params[@component].params
                      when :users then Users.api_params[@component].params
                      when :log_entries then Log_Entries.api_params[@component].params
                      when :alerts then Alerts.api_params[@component].params
                      when :schedules then Schedules.api_params[@component].params
                      when :services then Services.api_params[@component].params
                   end

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] list <component>"
      opts.separator ""
      opts.separator "      <component> is #{COMPONENTS.join(',')}"
      opts.separator ""
      api_params.each do |p,param|
        @params[p] = param.default
        opts.on("--#{p} #{param.param}", String, param.description)        { |o| @params[p] = o }
      end
      opts.order!(@arguments)

      @component = @arguments.shift.to_sym unless @arguments.empty?

      options_valid?
      process_options
      arguments_valid?
      process_arguments

      @log = options[:log]
      @list = case @component
                when :incidents     then Incidents.new @options[:subdomain],@options
                when :alerts        then Alerts.new @options[:subdomain],@options
                when :users         then Users.new @options[:subdomain],@options
                when :log_entries   then Log_Entries.new @options[:subdomain],@options
                when :schedules     then Schedules.new @options[:subdomain],@options
                when :services      then Services.new @options[:subdomain],@options
      end
    end

    def exec
      component_list = @list.find(@params)
      component_list.each { |i| puts i.to_s }
    end

    protected

    def options_valid?

    end

    def arguments_valid?

    end

    def process_options

    end

    def process_arguments

    end

  end

end end