require 'ostruct'
require 'time'
require 'rest_client'
require 'everpager/pagerduty/helpers'
require 'everpager/pagerduty/api/integration/events'
require 'everpager/pagerduty/api/rest'

module Everpager; module PagerDuty

  class Connection

    attr_reader :resource
    attr_accessor :body

    include Everpager::PagerDuty::Helpers

    def initialize(subdomain,options = {})
      @body = {}
      rest_client_options = { :headers => { :content_type => 'application/json', :user_agent => "Everpager" } }

      rest_client_base_path = nil
      case subdomain
        when '', nil?
          raise ArgumentError, "subdomain is unspecified"
        when 'events'
          # auth must contain :service_key, which will then be fed to params
          raise ArgumentError, "must specify service key" unless options[:service_key]
          rest_client_base_path = "https://events.pagerduty.com/generic"
          @body[:service_key] = options[:service_key]
          @body[:incident_key] = options[:incident_key]
        else
          # auth must contain :api_token or :username,:password tuple, which will be fed to headers
          rest_client_base_path = "https://#{subdomain}.pagerduty.com/api/v1"
          if options.has_key?(:api_token)
            rest_client_options[:headers][:authorization] = "Token token=#{options[:api_token]}"
          elsif options.has_key?(:username) and options.has_key?(:password)
            rest_client_options[:user] = options[:username]
            rest_client_options[:password] = options[:password]
          else
            raise ArgumentError, "must specify username/password or API Token autehntication"
          end
      end
      @resource = RestClient::Resource.new rest_client_base_path, rest_client_options
    end

  end

end end