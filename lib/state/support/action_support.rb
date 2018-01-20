# frozen_string_literal: true

# Support methods for actions
module ActionSupport
  # Configure the logger
  def set_logger(log_level = Logger::DEBUG, log = '/tmp/logfile.log')
    logger = Logger.new(log)
    logger.level = log_level
    original_formatter = Logger::Formatter.new
    logger.formatter = proc { |severity, datetime, progname, msg|
      original_formatter.call(severity, datetime, progname, msg.dump)
    }
    logger
  end

  # Control whether the main execution loop finishes
  def breakout
    query_state('BREAKOUT') == 1
  end

  # Updates the current run phase, which can be one of:
  # STARTUP RUNNING SHUTDOWN EMERGENCY_SHUTDOWN STOPPED
  def update_run_phase_state(run_phase)
    run_phase_flags.each do |flag|
      if flag == run_phase
        update_state(flag, 1)
      else
        update_state(flag, 0)
      end
    end
  end

  # Returns the current run phase, which can be one of:
  # STARTUP RUNNING SHUTDOWN EMERGENCY_SHUTDOWN STOPPED
  def query_run_phase_state
    run_phase_flags.each do |rpf|
      state = query_state(rpf).to_i
      return rpf unless state.zero?
    end
    raise 'Could not determine run phase from DB'
  end

  # run_mode is either NORMAL or RECOVERY
  # NORMAL - Normal running
  # RECOVERY - attempt to start up and recover a failed run
  def update_run_mode(run_mode)
    run_mode_flags.each do |flag|
      if flag == run_mode
        update_state(flag, 1)
      else
        update_state(flag, 0)
      end
    end
  end

  # Returns the current run state, which can be one of:
  # NORMAL RECOVERY
  def query_run_state
    run_mode_flags.each do |rsf|
      state = query_state(rsf).to_i
      return rsf unless state.zero?
    end
    raise 'Could not determine run state from DB'
  end
end