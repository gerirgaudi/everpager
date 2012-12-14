require 'ostruct'
require 'everpager/pagerduty/helpers'

module Everpager; module PagerDuty

  class Users < ApiComponents

    @api_path = "api/v1/#{self.name.downcase.split('::')[-1]}".freeze
    @api_params = { :users => OpenStruct.new( :params => { :query => OpenStruct.new(:description => 'Users whose names or email addresses match', :type => String,  :param => 'QUERY') } ) }
    @sprintf_options = { :format => "%7s %-25s %-25s %-8s", :fields => [ :id, :name, :email, :role] }

    Component.sprintf_options = self.sprintf_options

  end

end end
