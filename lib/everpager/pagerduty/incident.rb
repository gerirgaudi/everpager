require 'ostruct'
require 'time'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Incident

    include Helpers
    attr_reader :username, :password, :incidents, :total, :limit, :offset

    API_PATH = 'api/v1/incidents'
    API_PARAMS = { 'incidents' => OpenStruct.new( :params => {  :since            => OpenStruct.new(:description => 'Start of data range (ISO9601)',            :type => 'Date',  :param => 'DATE', :default => (Time.now - 60*60*24).iso8601 ),
                                                                :until            => OpenStruct.new(:description => 'End of date range (ISO8601)',              :type => 'Date',  :param => 'DATE'),
                                                                :fields           => OpenStruct.new(:description => 'Fields (comma separated)',                 :type => String,  :param => 'FIELDS'),
                                                                :status           => OpenStruct.new(:description => 'Status (triggered,acknowledged,resolved)', :type => String,  :param => 'STATUS'),
                                                                :incident_key     => OpenStruct.new(:description => 'Incident key',                             :type => String,  :param => 'KEY'),
                                                                :service          => OpenStruct.new(:description => 'Service IDs (comma separated)',            :type => String,  :param => 'ID'),
                                                                :assigned_to_user => OpenStruct.new(:description => 'User IDs (comma separated)',               :type => String,  :param => 'USER'),
                                                                :sort_by          => OpenStruct.new(:description => 'Sort order <field>:[asc|desc]',            :type => String,  :param => 'SORTSPEC')
                                                            }
                                                )
    }
    MET_PARAMS = [ :log, :api_access_key, :api_params ]

    def initialize(subdomain,options = {})
      setup_log(options[:log])
      api_path = options[:api_path] ? options[:api_path] : API_PATH
      @session = Session.new subdomain, api_path, options
    end

    def find(params)
      @response = IncidentsResponse.new @session.get params
      puts @response
    end

    def count
      @reponse

    end

    def acknowledge

    end

    def resolve

    end

    def escalate

    end



    protected

  end

  class IncidentsResponse

    def initialize(response)
      r = JSON.parse(response)
      @incidents = r['incidents']
      @limit = r['limit']
      @offset = r['offset']
      @total = r['total']
    end
  end

end end