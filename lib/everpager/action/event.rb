require 'everpager/pagerduty'

module Everpager; module Action

  include Everpager::PagerDuty::API::Integration

  class Event

    def initialize(service_key, params = {} )
      @event = Everpager::PagerDuty::API::Integration::Event.new service_key, params
      @log = params[:log]
    end

    def method_missing(method, *args, &block)
      description = args[0]
      details = args[1]
      @event.send(method,description,details)
    end

  end

end end