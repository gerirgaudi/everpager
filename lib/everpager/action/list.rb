require 'time'
require 'everpager/pagerduty'

module Everpager; module Action

  class List

    include Everpager::PagerDuty

    COMPONENTS = [ :incidents, :alerts, :users ]

    def initialize(arguments,options)

      @arguments = arguments
      @options = options
      @params = {}
      @component = @arguments.shift.to_sym unless @arguments.empty?
      raise StandardError, "invalid component #@component" unless COMPONENTS.include?(@component)

      api_params = Incident::API_PARAMS['incidents'].params

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
#      puts opts

      @component = @arguments.shift.to_sym unless @arguments.empty?

      options_valid?
      process_options
      arguments_valid?
      process_arguments

#      @list = { :incidents => self.method(:list_incidents),
#                :alerts => self.method(:list_alerts),
#                :users => self.method(:list_users)
#      }

      @list = Incident.new @options[:subdomain],@options

      @log = options[:log]
    end

    def exec
      @list.find @params
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

    def list_incidents

    end

    def list_alerts

    end

    def list_users

    end

  end

end end