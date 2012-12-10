require 'json'
require 'net/http'
require 'ostruct'
require 'everpager/pagerduty/helpers/session'

module Everpager

  module PagerDuty

    class PagerdutyError < StandardError; end

    class Event

      include Helpers


      EVENTS = {
          :trigger      => OpenStruct.new(:type => 'trigger',     :state => :triggered,     :display => 'Triggered'),
          :acknowledge  => OpenStruct.new(:type => 'acknowledge', :state => :acknowledged,  :display => 'Acknowleged'),
          :resolve      => OpenStruct.new(:type => 'resolve',     :state => :resolved,      :display => 'Resolved')
      }

      attr_reader :service_key, :incident_key, :status, :state, :error, :message, :description, :details

      def initialize(service_key, params = { :incident_key => nil, :api_path => "/generic/2010-04-15/create_event.json"} )
        @service_key = service_key
        @incident_key = incident_key
        @api_path = params[:api_path] ? params[:api_path] : "/generic/2010-04-15/create_event.json"
        @description = nil
        @details = {}
        @response = nil
        @session = Session.new("events",@api_path)
      end

      def trigger(description, details = {})
        event(:trigger,description,details)
      end

      def acknowledge(description, details = {})
        event(:acknowledge,description,details)
      end

      def resolve(description, details = {})
        event(:resolve,description,details)
      end

      protected

      def event(e,description,details = {})
        data = { :event_type => EVENTS[e].type, :service_key => @service_key, :description => description, :details => details }
        data.merge!({ :incident_key => @incident_key }) unless @incident_key == nil

        @response = EventResponse.new @session.post(data)
        raise PagerDutyError @response.message unless @response.status == :success

        @description = description
        @details = details
        @incident_key = @response.incident_key
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
        puts r
        exit 0
        @status = response["status"].to_sym
        @message = response["message"]
        @incident_key = response['incident_key']
      end

    end
  end
end