require 'json'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class ApiComponents

    @api_path = ''.freeze
    @api_params = {}.freeze
    @sprintf_options = {}

    def self.api_path
      @api_path
    end

    def self.api_params
      @api_params
    end

    def self.sprintf_options
      @sprintf_options
    end

    include Helpers

    def initialize(subdomain,options)
      setup_log(options[:log])
      @subdomain = subdomain
      @api_path = options[:api_path] ? options[:api_path] : self.class.api_path
      @options = options
      @api_component = self.class.to_s.downcase.split('::')[-1]
    end

    def find(params)
      @session = Session.new @subdomain, @api_path, @options
      @response = Response.new(@api_component,@session.get(params))
    end

    protected

    class Component < Hash

      @sprintf_options = {}

      def self.sprintf_options
        @sprintf_options
      end

      def self.sprintf_options=(options)
        @sprintf_options = options
      end


      def initialize(hash)
        hash.each do |key,value|
          self[key.to_sym] = value
        end
      end

      def to_s
        self.class.sprintf_options[:format] % self.class.sprintf_options[:fields].collect { |x| self[x] }
      end

    end

    class Response

      include Enumerable

      def initialize(api_component,response)
        @api_component = api_component
        r = JSON.parse(response)
        r.each do |key,value|
          if key == @api_component
            self.instance_variable_set("@#{key}", (value.collect { |x| Component.new(x) }))
          else
            self.instance_variable_set("@#{key}", value)
          end
        end
      end

      def each(&block)
        self.instance_variable_get("@#@api_component").each do |api_component|
          block.call(api_component)
        end
      end
    end

  end

end end