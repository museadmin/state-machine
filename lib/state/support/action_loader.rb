require 'state/actions/action_confirm_ready_to_run'
require 'state/actions/action_normal_shutdown'
require 'state/actions/action_emergency_shutdown'

require 'facets'


module ActionLoader

  # Default actions are hard coded here
  def load_default_actions(control)
    control[:actions]['CONFIRM_READY_TO_RUN'] = ActionConfirmReadyToRun.new(control)
    control[:actions]['NORMAL_SHUTDOWN'] = ActionNormalShutdown.new(control)
    control[:actions]['EMERGENCY_SHUTDOWN'] = ActionEmergencyShutdown.new(control)
  end

  # User actions are loaded dynamically from a directory
  def load_user_actions(control)

    Dir["#{control[:user_actions_dir]}/*.rb"].each do |file|
      require file
      file_name = File.basename(file, '.rb')
      class_name = file_name.upper_camelcase
      action = Object.const_get(class_name).new(control)
      control[:actions][action.flag] = action
    end

  end

end