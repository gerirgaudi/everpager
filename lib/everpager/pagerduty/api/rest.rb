require 'everpager/pagerduty/api/rest/collection'
require 'everpager/pagerduty/api/rest/incidents'
require 'everpager/pagerduty/api/rest/log_entries'
require 'everpager/pagerduty/api/rest/alerts'
require 'everpager/pagerduty/api/rest/schedules'
require 'everpager/pagerduty/api/rest/services'
require 'everpager/pagerduty/api/rest/users'

module Everpager; module PagerDuty; module API; module REST

  include ObjectSpace

  apis = {}
  ObjectSpace.each_object(Class) do |c|
    api_c_re = /^(Everpager::PagerDuty::API::REST)::([A-Za-z_]+)$/
    if c.to_s =~ api_c_re
      con = $2
      key = con.downcase.to_sym
      apis[key] = c
    end
  end
  APIS = apis

end end end end