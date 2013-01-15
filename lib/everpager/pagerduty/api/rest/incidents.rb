require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Incidents < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/incidents',
              :description => 'Current and historical PagerDuty incidents',
              :operations => [
                  { :httpMethod     => :get,
                    :nickname       => :find,
                    :responseClass  => 'List[Incident]',
                    :parameters => [
                        { :paramType      => :query,
                          :name           => 'since',
                          :description    => 'Start of date range (ISO8601)',
                          :datatype       => 'Date',
                          :default        => (Time.now - 60*60*1).iso8601,
                          :required       => false,
                          :allowMultiple  => false,
                        },
                        { :paramType      => :query,
                          :name           => 'until',
                          :description    => 'End of date range (ISO8601)',
                          :datatype       => 'Date',
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'fields',
                          :description    => 'Fields (comma separated)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'status',
                          :description    => 'Status (triggered,acknowledged,resolved)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'incident_key',
                          :description    => 'Incident key',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'service',
                          :description    => 'Service IDs (comma separated)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'assigned_to_user',
                          :description    => 'User IDs (comma separated)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'sort_by',
                          :description    => 'Sort order <field>:[asc|desc]',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        }
                    ]
                  }
              ]
            },
            { :path => '/incidents/count',
              :description => 'Count of incidents that match a given query',
              :operations => [
                  { :httpMethod => :get,
                    :nickname   => :count,
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
                          :name           => 'status',
                          :description    => 'Status (triggered,acknowledged,resolved)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'incident_key',
                          :description    => 'Incident key',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'service',
                          :description    => 'Service IDs (comma separated)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        },
                        { :paramType      => :query,
                          :name           => 'assigned_to_user',
                          :description    => 'User IDs (comma separated)',
                          :datatype       => String,
                          :required       => false,
                          :allowMultiple  => false
                        }
                    ]
                  }
              ]
            }
        ]
    )
    @sprintf_options = { :format => "%s:%-5d %-36s %-10s", :fields => [ :id, :incident_number, :incident_key, :status ] }

  end

end end end end