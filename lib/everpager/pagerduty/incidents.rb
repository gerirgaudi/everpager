require 'ostruct'
require 'time'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Incidents < ApiComponents

    @api_path = "api/v1/#{self.name.downcase.split('::')[-1]}".freeze
    @api_params = { :incidents => OpenStruct.new( :params => {  :since            => OpenStruct.new(:description => 'Start of data range (ISO9601)',            :type => 'Date',  :param => 'DATE', :default => (Time.now - 60*60*24*2).iso8601 ),
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
    @sprintf_options = { :format => "%s", :fields => [ :id ] }

    Component.sprintf_options = self.sprintf_options

  end

end end