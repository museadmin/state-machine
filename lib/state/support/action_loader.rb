# frozen_string_literal: true

require 'state/actions/action_confirm_ready_to_run'
require 'state/actions/action_normal_shutdown'
require 'state/actions/action_emergency_shutdown'

require 'facets'

# Load default and user actions
module ActionLoader
  # Default actions are hard coded here
  def load_default_actions(control)
    name = 'SYS_CONFIRM_READY_TO_RUN'
    control[:actions][name] = ActionConfirmReadyToRun.new(control, name)
    name = 'SYS_NORMAL_SHUTDOWN'
    control[:actions][name] = ActionNormalShutdown.new(control, name)
    name = 'SYS_EMERGENCY_SHUTDOWN'
    control[:actions][name] = ActionEmergencyShutdown.new(control, name)
  end

  # User actions are loaded dynamically from a directory
  def load_user_actions(control)
    Dir["#{control[:user_actions_dir]}/action_*.rb"].each do |file|
      require file
      file_name = File.basename(file, '.rb')
      name = file_name.upper_camelcase
      action = Object.const_get(name).new(control, name)
      control[:actions][file_name.upcase] = action
    end
  end
end