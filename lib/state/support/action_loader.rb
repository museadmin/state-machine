require 'state/actions/confirm_ready_to_run'
require 'facets'


module ActionLoader

  def load_default_actions(control)
    control[:actions]['CONFIRM_READY_TO_RUN'] = ConfirmReadyToRun.new(control)
  end

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