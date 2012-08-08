require 'json'
require 'net/http'

module Everpager

  module Pagerduty

    class PagerdutyError < StandardError; end

    class Incident

      INTEGRATION_API_URL = "https://events.pagerduty.com/generic/2010-04-15/create_event.json"

      INCIDENT_STATUS = {
          :triggered    => 'Triggered',
          :acknowledged => 'Acknowledged',
          :resolved     => 'Resolved'
      }

      attr_reader :service_key, :incident_key, :status, :state, :error, :message, :description, :details, :resp

      def initialize(service_key, incident_key = nil)
        @service_key = service_key
        @incident_key = incident_key
        @description = nil
        @details = {}
        @state = nil
        @status = nil
        @error = nil
        @message = nil
        @resp = nil
      end

      def trigger(description, details = {})
        @description = description
        @details = details
        @resp = api_call("trigger", @description, details = {})
        @state = :triggered
      end

      def acknowledge(description, details = {})
        @description = description
        @details = details
        @resp = api_call("acknowledge", @description, details = {})
        @state = :acknowledged
      end

      def resolve(description, details = {})
        @description = description
        @details = details
        @resp = api_call("resolve", @description, details = {})
        @state = :resolved
      end

      protected

      def api_call(event_type, description, details = {})
        params = { :event_type => event_type, :service_key => @service_key, :description => description, :details => details }
        params.merge!({ :incident_key => @incident_key }) unless @incident_key == nil

        url = URI.parse(INTEGRATION_API_URL)

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        req = Net::HTTP::Post.new(url.request_uri)

        req.body = JSON.generate(params)

        res = http.request(req)
        case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            @resp = JSON.parse(res.body)
            @status = @resp['status']
            @message = @resp['message']
            unless @status == "success"
              @error = @resp['error']
              raise PagerdutyError, "#@error: #@message"
            end
          else
            raise PagerdutyError, res.error!
        end
      end
    end

    class IncidentSet

      INCIDENT_API_URL = "https://enops.pagerduty.com/api/v1/incidents"

      attr_reader :username, :password, :incidents, :total, :limit, :offset

      def initialize(username,password)
        @username = username
        @password = password
        @filter = nil
        @incidents = nil
        @total = 0
        @limit = 0
        @offset = 0
      end

      protected

      def api_call(method=nil)
        url = URI.parse("#{INCIDENT_API_URL}/#{method}")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        req = Net::HTTP::Get.new(url.request_uri)
        req.basic_auth(@username,@password)

        res = http.request(req)
        case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            resp = JSON.parse(res.body)
            @incidents = resp["incidents"]
            @total = resp["total"]
            @offset = resp["offset"]
            @limit = resp["limit"]
          else
            raise PagerdutyError, res.error!
        end
      end
    end
  end
end