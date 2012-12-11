require 'everpager/pagerduty'

module Everpager; module Action

  class Event

    def initialize(service_key, params)
      @event = Everpager::PagerDuty::Event.new service_key, params
      @log = params[:log]
    end

    def method_missing(method, *args, &block)
      description = args[0]
      details = args[1]

      case method.to_sym
        when :trigger     then @event.trigger(description,details)
        when :acknowledge then @event.acknowledge(description,details)
        when :resolve     then @event.resolve(description,details)
        else super
      end
    end
  end

end end