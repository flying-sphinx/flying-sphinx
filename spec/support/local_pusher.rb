class LocalPusher
  attr_reader :connections

  def initialize
    @connections = []
  end

  def start
    @server_thread ||= Thread.new do
      EM.run { socket_server }
    end
  end

  def stop
    server_thread.kill
  end

  def send(event, data)
    connections.each do |connection|
      connection.send({
        'event'   => event,
        'data'    => data.to_json,
        'channel' => ENV['FLYING_SPHINX_IDENTIFIER']
      }.to_json)
    end
  end

  private

  attr_reader :server_thread

  def socket_server
    EM::WebSocket.run(
      :host => ENV['FLYING_SPHINX_SOCKETS_HOST'],
      :port => ENV['FLYING_SPHINX_SOCKETS_PORT']
    ) do |connection|
      connection.onopen do |handshake|
        connections << connection
        connection.send({
          'event' => 'pusher:connection_established',
          'data'  => {'socket_id' => 101}.to_json
        }.to_json)
      end

      connection.onclose { connections.delete connection }
    end
  end
end
