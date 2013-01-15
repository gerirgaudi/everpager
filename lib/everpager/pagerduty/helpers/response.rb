module Everpager; module PagerDuty; module Helpers

  class Response

    include Enumerable

    def initialize(component,response)
      @api_component = component
      r = JSON.parse(response)
      r.each do |key,value|
        if key == @api_component
          self.instance_variable_set("@#{key}", (value.collect { |x| Component.new(x) }))
        else
          self.instance_variable_set("@#{key}", value)
        end
      end
    end

    def each(&block)
      self.instance_variable_get("@#@api_component").each do |api_component|
        block.call(api_component)
      end
    end
  end

end end end