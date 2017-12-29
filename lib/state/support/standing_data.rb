# frozen_string_literal: true

# The default states always loaded by the state machine itself
def default_states
  [
    ['0', 'BREAKOUT', 'Break out of main execution loop in shutdown phase'],
    ['0', 'DEFAULT_ACTIONS_LOADED', 'Successfully loaded all default actions'],
    ['0', 'ACTION_PACK_LOADED', 'Successfully loaded an action pack'],
    # Run State
    ['1', 'NORMAL', 'Normal startup'],
    ['0', 'RECOVERY', 'Recovery mode'],
    # Run Phase
    ['1', 'STARTUP', 'We are starting up'],
    ['0', 'RUNNING', 'We are running normally']
  ]
end

# The run phases
def run_phase_flags
  %w[STARTUP RUNNING SHUTDOWN EMERGENCY_SHUTDOWN]
end

# The run modes
def run_mode_flags
  %w[NORMAL RECOVERY]
end