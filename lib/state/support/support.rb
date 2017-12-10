
module Support

  def set_logger(log_level = Logger::DEBUG)
    logger = Logger.new('logfile.log')
    logger.level = log_level
    original_formatter = Logger::Formatter.new
    logger.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call(severity, datetime, progname, msg.dump)
    }
    logger
  end

end