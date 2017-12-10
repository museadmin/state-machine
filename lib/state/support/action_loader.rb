require 'state/actions/confirm_ready_to_run'
require 'facets'


module ActionLoader

  def load_default_actions(hash)
    hash['ConfirmReadyToRun'.snakecase.upcase] = ConfirmReadyToRun.new
  end

  def load_user_actions(hash, path)

    Dir["#{path}/*.rb"].each do |file|
      require file
      file_name = File.basename(file, '.rb')
      class_name = file_name.upper_camelcase
      action = Object.const_get(class_name).new
      hash[action.flag] = action
    end

  end

end