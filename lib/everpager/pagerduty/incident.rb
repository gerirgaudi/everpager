require 'everpager/pagerduty/helpers/session'

module Everpager

  module PagerDuty

    class Incident

      INCIDENT_API_URL = "https://<domain>.pagerduty.com/api/v1/incidents"

      attr_reader :incident_number, :status, :created_on, :html_url, :incident_key, :service, :assigned_to_user, :last_status_change_by, :last_status_change_on, :trigger_summary_data, :trigger_details_html_url

      def initialize(session)
        @api_url = "https://#{domain}.pagerduty.com/api/v1/incidents"
      end

    end

    class Incidents

      include Enumerable

      INCIDENT_API_URL = "https://<domain>.pagerduty.com/api/v1/incidents"

      attr_reader :username, :password, :incidents, :total, :limit, :offset

      def initialize(domain,params = {})
        params_keys = [ :since, :until, :fields, :status, :incident_key, :service, :assigned_to_user, :sort_by ].freeze

        @response = session.get(api,query)

        @incidents = {}
        @total = 0
        @limit = 0
        @offset = 0
      end

      protected

    end

  end
end