require 'state/machine/version'
require 'state/required_actions'
require 'state/support/action_loader'
require 'state/support/support'

require 'logger'

class StateMachine

  include Support
  include ActionLoader

  attr_accessor :user_actions
  attr_reader :number_of_actions, :log

  # Constructor
  # @param args Argument Hash
  def initialize(args = {})
    @actions = {}
    @phase = 'STARTUP'
    @user_actions = args[:user_actions]
    @number_of_actions = 0
    @control = {
        :breakout => false
    }

    @log = args[:log]
    @logger = set_logger(Logger::DEBUG, @log)
    @logger.info('Starting State Machine')
  end

  # Load the default and user actions if existing
  def load_actions
    load_default_actions(@actions)
    load_user_actions(@actions, @user_actions) unless @user_actions.nil?
    @number_of_actions = @actions.size
  end

  # Main state machine loop
  def execute
    loop do
      @actions.each do |flag, action|
        action.execute({phase: @phase, actions: @actions, control: @control})
        break if @control[:breakout]
      end
      break if @control[:breakout]
    end
  end

end


