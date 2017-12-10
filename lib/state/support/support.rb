
module Support

  def set_logger(log_level = Logger::DEBUG, log = '/tmp/logfile.log')
    logger = Logger.new(log)
    logger.level = log_level
    original_formatter = Logger::Formatter.new
    logger.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call(severity, datetime, progname, msg.dump)
    }
    logger
  end

end