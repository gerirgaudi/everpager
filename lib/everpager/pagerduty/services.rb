require 'ostruct'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Services < ApiComponents

    @api_path = "api/v1/#{self.name.downcase.split('::')[-1]}".freeze
    @api_params = { :services => OpenStruct.new( :params => { :query => OpenStruct.new(:description => 'Users whose names or email addresses match', :type => String,  :param => 'QUERY') } ) }
    @sprintf_options = { :format => "%7s %-25s %-25s %-8s", :fields => [ :id, :name, :service_key, :status] }

    Component.sprintf_options = self.sprintf_options

  end

end end
