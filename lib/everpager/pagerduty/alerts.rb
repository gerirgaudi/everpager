require 'ostruct'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Alerts < ApiComponents

    @api_path = "api/v1/#{self.name.downcase.split('::')[-1]}".freeze
    @api_params = { :alerts => OpenStruct.new( :params => {  :since            => OpenStruct.new(:description => 'Start of data range (ISO9601)',            :type => 'Date',  :param => 'DATE', :default => (Time.now - 60*60*24*2).iso8601 ),
                                                             :until            => OpenStruct.new(:description => 'End of date range (ISO8601)',              :type => 'Date',  :param => 'DATE') }
    )
    }
    @sprintf_options = { :format => "%7s %-25s %-25s %-8s", :fields => [ :id, :name, :email, :role] }

    Component.sprintf_options = self.sprintf_options

  end

end end
