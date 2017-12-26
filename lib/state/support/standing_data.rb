# frozen_string_literal: true

def default_states
  [
    ['0', 'BREAKOUT', 'Break out of main execution loop in shutdown phase'],
    ['0', 'ACTIONS_LOADED', 'Successfully loaded all actions'],
    # Run State
    ['1', 'NORMAL', 'Normal startup'],
    ['0', 'RECOVERY', 'Recovery mode'],
    # Run Phase
    ['1', 'STARTUP', 'We are starting up'],
    ['0', 'RUNNING', 'We are running normally']
  ]
end

def run_phase_flags
  %w[STARTUP RUNNING SHUTDOWN EMERGENCY_SHUTDOWN]
end

def run_mode_flags
  %w[NORMAL RECOVERY]
end