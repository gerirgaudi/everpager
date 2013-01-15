require 'ostruct'
require 'json'

module Everpager; module PagerDuty; module API

  class Collection

    include Everpager::PagerDuty::Helpers

    class << self; attr_reader :api, :sprintf_options end
    @api = nil
    @sprintf_options = nil

    def self.find(connection, params = {})
      endpoint = self.api.by_nickname[__method__][:path]
      begin
        response = connection.resource[endpoint].get :params => params
        if response.code == 200
          JSON.parse(response.to_str)[self.name.split('::')[-1].downcase]
        else
          nil
        end
      rescue RestClient::Exception => e
        puts e.message
        puts JSON.parse(e.response).inspect
      end
    end

    def self.count(params)
      conn = params[:connection]
      params.delete(:connection)
      endpoint = self.api.by_nickname[__method__][:path]
      response = conn.resource[endpoint].get params
    end

  end

  class Component < Hash

    @sprintf_options = {}

    def self.sprintf_options
      @sprintf_options
    end

    def self.sprintf_options=(options)
      @sprintf_options = options
    end


    def initialize(hash)
      puts self.class
      hash.each do |key,value|
        self[key.to_sym] = value
      end
    end

    def to_s
      self.class.sprintf_options[:format] % self.class.sprintf_options[:fields].collect { |x| self[x] }
    end

  end

end end end