require 'everpager/pagerduty/helpers/api'

module Everpager; module PagerDuty; module API; module REST

  class Services < Collection

    @api = Everpager::PagerDuty::Helpers::API.new(
        :basePath   => 'https://{subdomain}.pagerduty.com/api',
        :apiVersion => 'v1',
        :apis => [
            { :path => '/services',
              :description => 'List existing services.',
              :operations => [
                  { :httpMethod =>  :get,
                    :nickname   =>  :find,
                    :parameters => [
                        { :paramType      => :query,
                          :name           => 'include',
                          :description    => 'Array of additional details to include. This API accepts escalation_policy and email_filters.',
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

    @sprintf_options = { :format => "%7s %-25s %-25s %-8s", :fields => [ :id, :name, :service_key, :status] }

  end

end end end end
