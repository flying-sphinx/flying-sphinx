require 'timeout'

class FlyingSphinx::Action
  def self.perform(identifier, timeout = 60, &block)
    new(identifier, timeout, &block).perform
  end

  def initialize(identifier, timeout, &block)
    @identifier, @timeout, @block = identifier, timeout, block
    @action_id = 0
    @finished  = false
  end

  def perform
    Timeout.timeout(timeout) do
      socket.connect true

      subscribe_to_events

      sleep 0.5 until socket.connected
      start
      sleep 0.5 until finished
    end

    true
  rescue Timeout::Error => error
    FlyingSphinx.logger.warn "Action timed out. If this is happening regularly, please contact Flying Sphinx support: http://support.flying-sphinx.com"

    return false
  ensure
    socket.disconnect
  end

  private

  attr_reader :identifier, :block, :action_id, :finished, :timeout

  def completion(data)
    FlyingSphinx.logger.debug "Completion: #{data}"
    data = MultiJson.load(data)

    @finished = (data['id'] == action_id)
  end

  def debug(data)
    FlyingSphinx.logger.debug "Progress: #{data}"
    data = MultiJson.load(data)

    puts data['data'] if data['data'] && data['data'].length > 0
  end

  def failure(data)
    FlyingSphinx.logger.debug "Failure: #{data}"
    data = MultiJson.load(data)

    if data['id'] == action_id
      FlyingSphinx.logger.warn 'Action failed.'
      @finished = true
    end
  end

  def response
    attempts = 0
    @response ||= begin
      block.call
    rescue
      attempts += 1
      retry if attempts <= 3
      raise
    end
  end

  def socket
    @socket ||= PusherClient::Socket.new FlyingSphinx::API::PUSHER_KEY,
      :encrypted => true
  end

  def start
    raise "Action blocked" if response['status'] == 'BLOCKED'

    @action_id = response['id']
  end

  def subscribe_to_events
    socket.subscribe identifier
    socket[identifier].bind 'debug',      &method(:debug)
    socket[identifier].bind 'completion', &method(:completion)
    socket[identifier].bind 'failure',    &method(:failure)
  end
end
