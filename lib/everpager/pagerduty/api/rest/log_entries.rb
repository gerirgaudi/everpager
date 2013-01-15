require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Log_Entries < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/log_entries',
              :description  => 'List all incident log entries across the entire account.',
              :operations   => [
                  { :httpMethod     => :get,
                    :nickname       => :find,
                    :responseClass  => 'List[Log_Entries]',
                    :parameters => [
                        { :paramType      => :query,
                          :name           => 'since',
                          :description    => 'Start of date range (ISO8601)',
                          :datatype       => 'Date',
                          :default        => (Time.now - 60*60*24*2).iso8601,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'until',
                          :description    => 'End of date range (ISO8601)',
                          :datatype       => 'Date',
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'is_overview',
                          :description    => 'Return log entries of type trigger, acknowledge, or resolve when true',
                          :datatype       => 'Boolean',
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'include',
                          :description    => 'Array of additional details to include. This API accepts channel, incident, and service.',
                          :datatype       => 'List',
                          :required       => false,
                          :allowMultiple  => false
                        }
                      ]
                  }
              ]
            }
        ]
    )

    @sprintf_options = { :format => "%15s %-25s", :fields => [ :created_at, :type ] }

  end

end end end end