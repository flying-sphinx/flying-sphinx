class SuccessfulAction
  attr_writer :result

  def initialize(action_id)
    @action_id = action_id
    @result    = nil
  end

  def matches?(block)
    pusher.start
    Thread.report_on_exception = false
    thread = Thread.new { call block }
    sleep 1.5

    pusher.send 'completion', 'id' => action_id
    thread.join
    pusher.stop

    sleep 0.5

    result
  end

  def failure_message_for_should
    "Action failed"
  end

  def supports_block_expectations?
    true
  end

  private

  attr_reader :action_id, :result

  def call(block)
    self.result = block.call
  end

  def pusher
    @pusher ||= LocalPusher.new
  end
end

module SuccessfulActionHelper
  def be_successful_with(action_id)
    SuccessfulAction.new action_id
  end
end

RSpec.configure do |config|
  config.include SuccessfulActionHelper
end
