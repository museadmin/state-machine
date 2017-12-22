
def default_states
  [
    ['1', 'STARTUP', 'We are still starting up'],
    ['0', 'SHUTDOWN', 'We are shutting down normally'],
    ['0', 'RUNNING', 'We are running normally'],
    ['0', 'EMERGENCY_EXIT', 'State machine has a bug, cannot be trusted'],
    ['0', 'ACTIONS_LOADED', 'Successfully loaded all actions']
  ]
end

