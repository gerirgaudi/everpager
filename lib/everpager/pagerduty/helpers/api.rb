module Everpager; module PagerDuty; module Helpers

  class API

    attr_reader :spec, :by_path, :by_nickname

    def initialize(spec)
      @spec = spec
      @by_path = api_by_path
      @by_nickname = api_by_nickname
    end

    protected

    def api_by_path
      by_path = {}
      @spec[:apis].each { |api| by_path[api[:path]] = api }
      by_path
    end

    def api_by_nickname
      by_nickname = {}
      @spec[:apis].each do |api|
        path = api[:path]
        api[:operations].each { |operation| by_nickname[operation[:nickname]] = { :path => path, :operation => operation } }
      end
      by_nickname
    end

  end

end end end