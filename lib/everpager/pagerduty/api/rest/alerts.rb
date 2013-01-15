require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Alerts < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/alerts',
              :description => 'List existing alerts for a given time range, optionally filtered by type (SMS, Email or Phone).',
              :operations => [
                  { :httpMethod =>  :get,
                    :nickname   =>  :find,
                    :parameters => [
                        { :paramType        => :query,
                          :name             => 'since',
                          :description      => 'Start of date range (ISO8601)',
                          :datatype         => 'Date',
                          :default          => (Time.now - 60*60*24).iso8601,
                          :required         => false,
                          :allowMultiple    => false
                        },
                        { :paramType        => :query,
                          :name             => 'until',
                          :description      => 'End of date range (ISO8601)',
                          :datatype         => 'Date',
                          :default          => Time.now.iso8601,
                          :required         => false,
                          :allowMultiple    => false
                        },
                        { :paramType        => :query,
                          :name             => 'filter[type]',
                          :description      => 'Returns only the alerts of the said types. Can be one of SMS, Email or Phone',
                          :allowableValues  => {
                              :valueType  => :list,
                              :values     => %w(SMS Phone Email)
                          },
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
    @sprintf_options = { :format => "%7s %-5s %-25s %-25s", :fields => [ :id, :type, :address, :started_at] }

  end

end end end end
