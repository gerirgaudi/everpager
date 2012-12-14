require 'ostruct'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Log_Entries < ApiComponents

    @api_path = "api/v1/#{self.name.downcase.split('::')[-1]}"
    @api_params = { :log_entries => OpenStruct.new( :params => {  :since       => OpenStruct.new(:description => 'Start of data range (ISO9601)',  :type => 'Date',  :param => 'DATE', :default => (Time.now - 60*60*96).iso8601 ),
                                                                  :until       => OpenStruct.new(:description => 'End of date range (ISO8601)',    :type => 'Date',  :param => 'DATE'),
                                                                  :is_overview => OpenStruct.new(:description => 'Overview mode',                  :type => String,  :param => nil   ),
                                                                  :include     => OpenStruct.new(:description => 'Channel',                        :type => String,  :param => 'CHANNEL')
    })}
    @sprintf_options = { :format => "%15s %-25s", :fields => [ :created_at, :type ] }

    Component.sprintf_options = self.sprintf_options

  end

end end