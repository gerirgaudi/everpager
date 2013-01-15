require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Schedules < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/schedules',
              :description => 'List existing on-call schedules.',
              :operations => [
                  { :httpMethod     =>  :get,
                    :nickname       =>  :find,
                    :responseClass  => 'List[Services]',
                    :parameters     => [
                        { :paramType      => :query,
                          :name           => 'query',
                          :description    => 'Filters the result, showing only the schedules whose name matches the query.',
                          :datatype       => 'String',
                          :required       => false,
                          :allowMultiple  => false
                        },
                        {
                          :paramType      => :query,
                          :name           => 'requester_id',
                          :description    => 'User id of the user making the request.',
                          :datatype       => 'String',
                          :required       => false,
                          :allowMultiple  => false
                        }
                    ]
                  }
              ]
            }
        ]
    )
    @sprintf_options = { :format => "%7s %-25s %-25s", :fields => [ :id, :name, :time_zone ] }

  end

end end end end
