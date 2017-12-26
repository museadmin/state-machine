# frozen_string_literal: true

def default_states
  [
    ['0', 'BREAKOUT', 'Break out of main execution loop in shutdown phase'],
    ['1', 'STARTUP', 'We are still starting up'],
    ['0', 'ACTIONS_LOADED', 'Successfully loaded all actions'],
    # Run State
    ['1', 'NORMAL', 'Normal startup'],
    ['0', 'RECOVERY', 'Recovery mode'],
    # Run Phase
    ['1', 'STARTUP', 'We are starting up'],
    ['0', 'RUNNING', 'We are running normally'],
    ['0', 'SHUTDOWN', 'We are shutting down'],
    ['0', 'EMERGENCY_SHUTDOWN', 'We are in an emergency shutdown']
  ]
end

class RunPhase
  attr_accessor :startup, :running, :shutdown, :emergency_shutdown
  def initialize
    @startup = 0
    @running = 0
    @shutdown = 0
    @emergency_shutdown = 0
  end

  def update_values
    [
        ['STARTUP', @startup],
        ['RUNNING', @running],
        ['SHUTDOWN', @shutdown],
        ['EMERGENCY_SHUTDOWN', @emergency_shutdown]
    ]
  end

  def run_phase_flags
    %w(STARTUP RUNNING SHUTDOWN EMERGENCY_SHUTDOWN)
  end
end

class RunState
  attr_accessor :normal, :recovery
  def initialize
    @normal = 0
    @recovery = 0
  end

  def update_values
    [
        ['NORMAL', @normal],
        ['RECOVERY', @recovery]
    ]
  end

  def run_state_flags
    %w(NORMAL RECOVERY)
  end
end