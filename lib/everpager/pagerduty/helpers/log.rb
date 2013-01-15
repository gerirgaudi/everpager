module Everpager; module PagerDuty; module Helpers

  def setup_log(log)
    if log.nil?
      @log = Logger.new(STDERR)
      @log.level = Logger::DEBUG
    else
      @log = log
    end
    @log
  end

end end end