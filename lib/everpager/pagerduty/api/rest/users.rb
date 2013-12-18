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
                    :nickname       => :find_all,
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
            },
            { :path         => '/users/{id}',
              :description  => 'Get information about an existing user.',
              :operations => [
                  { :httpMethod   => :get,
                    :nickname     => :find,
                    :responseClass  => 'User',
                    :parameters     => [
                        { :paramType      => :path,
                          :name           => 'id',
                          :description    => 'User Id (not username)',
                          :datatype       => 'String',
                          :required       => true,
                          :allowMultiple  => false
                        }
                    ]
                  }
              ]
            }
        ]
    )

    @sprintf_options = { :format => "%7s %-29s %-25s %-8s", :fields => [ :id, :name, :email, :role ] }

  end

end end end end
