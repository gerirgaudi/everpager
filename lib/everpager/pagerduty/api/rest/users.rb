require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Users < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/users',
              :description  => 'List users of your PagerDuty account, optionally filtered by a search query',
              :operations   => [
                  { :httpMethod     => :get,
                    :nickname       => :find,
                    :responseClass  => 'List[Users]',
                    :parameters => [
                        { :paramType      => :query,
                          :name           => 'query',
                          :description    => 'Filters the result, showing only the users whose names or email addresses match the query',
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

    @sprintf_options = { :format => "%7s %-25s %-25s %-8s", :fields => [ :id, :name, :email, :role ] }

  end

end end end end
