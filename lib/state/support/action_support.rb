
module ActionSupport

  def set_logger(log_level = Logger::DEBUG, log = '/tmp/logfile.log')
    logger = Logger.new(log)
    logger.level = log_level
    original_formatter = Logger::Formatter.new
    logger.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call(severity, datetime, progname, msg.dump)
    }
    logger
  end

  def breakout
    (query_property('breakout').to_s =~ /^[Tt]rue$/i) == 0
  end

end