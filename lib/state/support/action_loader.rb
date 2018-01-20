# frozen_string_literal: true

require 'state/actions/action_confirm_ready_to_run'
require 'state/actions/action_normal_shutdown'
require 'state/actions/action_emergency_shutdown'
require 'facets'

# Load default and user actions
module ActionLoader
  # Default actions are hard coded here
  def load_default_actions
    args = { run_mode: @run_mode, logger: @logger }
    name = 'SYS_CONFIRM_READY_TO_RUN'
    @actions[name] = ActionConfirmReadyToRun.new(args, name)
    name = 'SYS_NORMAL_SHUTDOWN'
    @actions[name] = ActionNormalShutdown.new(args, name)
    name = 'SYS_EMERGENCY_SHUTDOWN'
    @actions[name] = ActionEmergencyShutdown.new(args, name)

    update_state('DEFAULT_ACTIONS_LOADED', 1)
  end

  # User actions are loaded dynamically from a directory
  # @param path [String] Absolute path to the action pack
  def load_action_pack(path)
    args = { run_mode: @run_mode, logger: @logger }
    Dir["#{path}/action_*.rb"].each do |file|
      require file
      file_name = File.basename(file, '.rb')
      name = file_name.upper_camelcase
      action = Object.const_get(name)
                   .new(args,
                        file_name.snakecase.upcase)
      @actions[file_name.snakecase.upcase] = action
    end
  end
end