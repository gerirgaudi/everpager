require 'time'
require 'everpager/pagerduty'

module Everpager; module Action

  class List

    include Everpager::PagerDuty

    COLLECTIONS = Everpager::PagerDuty::API::REST::APIS

    def initialize(arguments,options)

      @log = options[:log]

      c_options = {}
      if options.has_key?(:key)
        c_options[:api_token] = options[:key]
      elsif options.has_key?(:username) and options.has_key?(:password)
        c_options[:username],c_options[:password] = options[:username],options[:password]
      end

      @params = {}

      @collection = arguments.shift.to_sym unless arguments.empty?
      raise ArgumentError, "invalid argument #{@collection}" unless COLLECTIONS.has_key?(@collection)

      api_params = COLLECTIONS[@collection].api.by_nickname[:find][:operation][:parameters]

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] list <collection>"
      opts.separator ""
      opts.separator "      <component> is #{COLLECTIONS.keys.join(',')}"
      opts.separator ""
      api_params.each do |param|
        @params[param[:name]] = param[:default] unless param[:default].nil?
        opts.on("--#{param[:name]} #{param[:datatype]}", String, param[:description])        { |o| @params[param[:name]] = o }
      end
      opts.order!(arguments)

      options_valid?
      process_options
      arguments_valid?
      process_arguments

      @connection = Connection.new options[:subdomain], c_options
    end

    def exec
      list = COLLECTIONS[@collection].find_all @connection, @params
      list.each do |item|
        printf "#{COLLECTIONS[@collection].sprintf_options[:format]}\n" % COLLECTIONS[@collection].sprintf_options[:fields].collect { |i| item[i.to_s] }
      end
    end

    protected

    def options_valid?

    end

    def arguments_valid?

    end

    def process_options

    end

    def process_arguments

    end

  end

end end