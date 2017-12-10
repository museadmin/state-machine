require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'state/support/support'

require 'logger'

class StateMachine

  include Support
  include ActionLoader

  def initialize
    @actions = {}
    @phase = 'STARTUP'

    @logger = set_logger
    @logger.info('Starting State Machine')
  end

  def load_actions
    load_default_actions(@actions)
    load_user_actions(@actions, '/Users/atkinsb/RubymineProjects/state-machine/user_actions')
  end

  def execute
    @actions.each do |flag, action|
      action.execute(@phase)
    end
  end

end


