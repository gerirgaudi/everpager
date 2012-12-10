require 'everpager/pagerduty'

module Everpager; module Action

  class Show

    include PagerDuty

    COMPONENTS = %w(incidents alerts users)

    def initialize(arguments,options)

      @options = options
      @arguments = arguments

      @component = nil

      opts = OptionParser.new
      opts.banner = "Usage: #{ID} [options] show <argument>"
      opts.separator ""
      opts.separator "      <argument> is incidents, alerts, users"
      opts.order!(@arguments)

      options_valid?
      arguments_valid?
      process_arguments

      @show = { :incidents  => self.method(:show_incidents),
                :alerts     => self.method(:show_alerts),
                :users      => self.method(:show_users)
      }
    end

    def exec
      @lsi = LSI.new(:megacli => @options[:megacli], :fake => @options[:fake], :hint => @component)
      @show[@component].call
    end

    protected

    def options_valid?
      true
    end

    def arguments_valid?
      raise ArgumentError, "missing component" if @arguments.size == 0
      raise ArgumentError, "too many components" if @arguments.size > 1
      raise ArgumentError, "invalid component #{@arguments[0]}" unless COMPONENTS.include? @arguments[0]
      true
    end

    def process_arguments
    end

    def show_incidents
    end

    def show_alerts
    end

    def show_users
      p = PDsession.new(domain)

    end
  end

end end