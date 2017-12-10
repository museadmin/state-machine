require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'logger'


module State

  module Machine

    logger = Logger.new('logfile.log')
    logger.level = Logger::DEBUG
    original_formatter = Logger::Formatter.new
    logger.formatter = proc { |datetime, severity, progname, msg|
      original_formatter.call(datetime, severity, progname, msg.dump)
    }

    logger.info('Starting State Machine')

    extend ActionLoader
    actions = {}
    load_default_actions(actions)
    load_user_actions(actions, '/Users/atkinsb/RubymineProjects/state-machine/user_actions')

    @phase = 'STARTUP'
    actions.each do |flag, action|
      action.execute(@phase)
    end

    logger.close
  end
end
