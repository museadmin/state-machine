require 'state/actions/parent_action'

class ActionNormalShutdown < ParentAction

  def initialize(control)

    @flag = 'NORMAL_SHUTDOWN'

    @states = [
        ['0', 'SHUTDOWN', 'We are shutting down normally']
    ]

    if control[:run_state] == 'NORMAL'
      @phase = 'ALL'
      @activation = 'SKIP'
      @payload = 'NULL'
      super(control)
    elsif
      recover_action(self)
    end

  end

  def execute(control)

    if active

      # Check the state flags that indicate we're ready to run
      puts @flag

      update_state('SHUTDOWN', 1)
      update_state('RUNNING', 0)
      update_state('READY_TO_RUN', 0)
      update_property('phase', 'SHUTDOWN')
      update_property('breakout', true)
    end

  ensure
    update_action(self)
  end

end
