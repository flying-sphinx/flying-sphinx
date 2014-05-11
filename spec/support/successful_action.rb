class SuccessfulAction
  attr_writer :result

  def initialize(action_id)
    @action_id = action_id
    @result    = nil
  end

  def matches?(block)
    pusher.start
    thread = Thread.new { call block }
    sleep 0.5

    pusher.send 'completion', 'id' => action_id
    thread.join
    pusher.stop

    result
  end

  def failure_message_for_should
    "Action failed"
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
