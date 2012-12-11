require 'json'
require 'net/http'
require 'ostruct'
require 'logger'
require 'everpager/pagerduty/helpers/session'

module Everpager; module PagerDuty

    class PagerDutyError < StandardError; end

    class Event

      include Helpers

      EVENTS = {
          :trigger      => OpenStruct.new(:type => 'trigger',     :state => :triggered,     :display => 'Triggered'),
          :acknowledge  => OpenStruct.new(:type => 'acknowledge', :state => :acknowledged,  :display => 'Acknowleged'),
          :resolve      => OpenStruct.new(:type => 'resolve',     :state => :resolved,      :display => 'Resolved')
      }

      attr_reader :service_key, :incident_key, :status, :state, :error, :message, :description, :details

      def initialize(service_key, params = {} )
        @service_key = service_key
        @incident_key = params[:incident_key]
        @api_path = params[:api_path] ? params[:api_path] : "/generic/2010-04-15/create_event.json"
        @description = nil
        @details = {}
        @response = nil
        @session = Session.new "events",@api_path
        @log = setup_log(params[:log])
      end

      def method_missing(method, *args, &block)
        description = args[0]
        details = args[1]

        case method.to_sym
          when :trigger     then event :trigger, description, details
          when :acknowledge then event :acknowledge, description, details
          when :resolve     then event :resolve, description, details
          else super
        end
      end

      protected

      def event(e,description,details = {})
        data = { :event_type => EVENTS[e].type, :service_key => @service_key, :description => description, :details => details }
        data.merge!({ :incident_key => @incident_key }) unless @incident_key == nil

        @log.debug "data: #{data}"

        @response = EventResponse.new @session.post(data)
        raise PagerDutyError @response.message unless @response.status == :success

        @description = description
        @details = details
        @incident_key = @response.incident_key
      end

      def setup_log(log)
        if log.nil?
          @log = Logger.new(STDERR)
          @log.level = Logger::FATAL
        else
          @log = log
        end
        @log
      end
    end

    class EventResponse

      # {
      #   "status": "success",
      #   "message": "Event processed",
      #  "incident_key": "srv01/HTTP"
      # }

      attr_reader :status, :message, :incident_key

      def initialize(response)
        r = JSON.parse(response)
        @status = r["status"].to_sym
        @message = r["message"]
        @incident_key = r['incident_key']
      end

    end
  end
end