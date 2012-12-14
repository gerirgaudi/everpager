require 'net/http'
require 'everpager/about'
require 'everpager/version'
require 'everpager/pagerduty/helpers/log'

module Everpager; module PagerDuty; module Helpers

  class Session

    VALID_PARAMS = [ :ssl, :api_access_key, :username, :password ]

    def initialize(api_subdomain, api_path, options = {} )
      @http = {}
      @http[:url] = "https://#{api_subdomain}.pagerduty.com/#{api_path}"
      @http[:headers] = { "Content-type" => "application/json", "User-Agent" => "#{ME.capitalize}/#{VERSION}" }
      @http[:headers]['Authorization'] = "Token token=#{options[:api_key]}" if options[:api_key]
      @http[:basic_auth] = { :username => options[:username], :password =>  option[:password] } if options[:username]

      @log = options[:log]
    end

    def get(params)
      api :get, params
    end

    def post(data)
      api :post, :data => JSON.generate(data)
    end

    def put(params)
      api :put
    end

    protected

    def api(http_method,params = {})
      uri = URI.parse("#{@http[:url]}")
      @log.debug uri
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = nil
      case http_method
        when :get
          uri.query = URI.encode_www_form(params)
          req = Net::HTTP::Get.new(uri.request_uri)
        when :post
          req = Net::HTTP::Post.new(uri.request_uri)
          req.body = JSON.generate(params)
        when :put
          req = Net::HTTP::Put.new(uri.request_uri)
        else raise Net::HTTPBadRequest
      end

      req.basic_auth(@http[:basic_auth][:username],@http[:basic_auth][:password]) if @http[:basic_auth]

      @http[:headers].each do |k,v|
        req[k] = v
      end

      res = http.request(req)

      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          return res.body
        else
          raise PagerDutyError, res.error!
      end
    end

    def verify_params(params)
      invalid_params = params.keys - VALID_PARAMS
      raise ArgumentError, "invalid param(s): #{invalid_params.join(', ')}" if invalid_params.any?
    end

  end

end end end