require 'net/http'
require 'everpager/about'

module Everpager; module PagerDuty; module Helpers

  class Session

    VALID_PARAMS = [ :ssl, :api_access_key, :username, :password ]

    def initialize(api_domain, api_path, params = {} )
      verify_params(params)

      @http = {}
      @http[:url] = "https://#{api_domain}.pagerduty.com/#{api_path}"
      @http[:headers] = { "Content-type" => "application/json", "User-Agent" => "#{ME}" }
      @http[:headers]["Authorization"] = "Token token=#{params[:api_access_key]}" if params[:api_access_key]
      @http[:basic_auth] = { :username => params[:username], :password =>  params[:password] } if params[:username]

    end

    def get
      api :get
    end

    def post(data)
      api :post, :data => JSON.generate(data)
    end

    protected

    def api(http_method,params = {})
      url = params[:api_method].nil? ? URI.parse("#{@http[:url]}") : URI.parse("#{@http[:url]}/#{params[:api_method]}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      req = case http_method
              when :get   then  Net::HTTP::Get.new(url.request_uri)
              when :post  then  Net::HTTP::Post.new(url.request_uri)
              else raise Net::HTTPBadRequest
            end
      req.basic_auth(@http[:basic_auth][:username],@http[:basic_auth][:password]) if @http[:basic_auth]
      @http[:headers].each do |k,v|
        req[k] = v
      end
      req.body = params[:data] if http_method == :post

      res = http.request(req)

      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          return res.body
        else
          raise PagerdutyError, res.error!
      end
    end

    def verify_params(params)
      invalid_params = params.keys - VALID_PARAMS
      raise ArgumentError, "invalid param(s): #{invalid_params.join(', ')}" if invalid_params.any?
    end

  end

end end end