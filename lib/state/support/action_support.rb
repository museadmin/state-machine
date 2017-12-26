# frozen_string_literal: true

# Support methods for actions
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
    query_state('BREAKOUT') == 1
  end

  def update_run_phase_state(run_phase)
    run_phase.update_values.each do |phase|
      update_state(phase[0], phase[1])
    end
  end

  def query_run_phase_state
    rps = RunPhase.new
    rps.run_phase_flags.each do |rpf|
      state = query_state(rpf)
      return rpf unless state == 0
    end
    raise 'Could not determine run phase from DB'
  end

  def update_run_state(run_state)
    run_state.update_values.each do |phase|
      update_state(phase[0], phase[1])
    end
  end

  def query_run_state
    rs = RunState.new
    rs.run_state_flags.each do |rsf|
      state = query_state(rsf)
      return rsf unless state == 0
    end
    raise 'Could not determine run state from DB'
  end
end