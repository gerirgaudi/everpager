require 'json'
require 'ostruct'
require 'everpager/pagerduty'
require 'awesome_print'


module Everpager; module PagerDuty; module API; module Integration

    class Event

      class PagerDutyError < StandardError; end

      EVENTS = {
          :trigger      => OpenStruct.new(:type => 'trigger',     :state => :triggered,     :display => 'Triggered'),
          :acknowledge  => OpenStruct.new(:type => 'acknowledge', :state => :acknowledged,  :display => 'Acknowleged'),
          :resolve      => OpenStruct.new(:type => 'resolve',     :state => :resolved,      :display => 'Resolved')
      }

      attr_reader :service_key, :incident_key, :status, :state, :error, :message, :description, :details

      def initialize(service_key, params = {} )
        @description = nil
        @details = {}
        @response = nil
        @log = params[:log]
        @connection = Connection.new 'events', :service_key => service_key, :incident_key => params[:incident_key]
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
        data = { :event_type => EVENTS[e].type, :description => description, :details => details, :service_key => @connection.body[:service_key], :incident_key => @connection.body[:incident_key] }
        @log.debug data

        begin
          @response = @connection.resource['2010-04-15/create_event.json'].post(data.to_json)
          @description = description
          @details = details
          @incident_key = JSON.parse(@response.body)['incident_key']
        rescue RestClient::BadRequest => e
          response = JSON.parse(e.response)
          raise PagerDutyError, "#{response['status']}: #{response['errors'][0]}"
        end
      end

      class Response

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
end end end