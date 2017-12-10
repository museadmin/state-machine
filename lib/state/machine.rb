require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'state/support/support'

require 'logger'

class StateMachine

  include Support
  include ActionLoader

  attr_accessor :user_actions
  attr_reader :number_of_actions

  def initialize(user_actions = nil)
    @actions = {}
    @phase = 'STARTUP'
    @user_actions = user_actions
    @number_of_actions = 0

    @logger = set_logger
    @logger.info('Starting State Machine')
  end

  def load_actions
    load_default_actions(@actions)
    load_user_actions(@actions, @user_actions)
    @number_of_actions = @actions.size
  end

  def execute
    @actions.each do |flag, action|
      action.execute(@phase)
    end
  end

end


