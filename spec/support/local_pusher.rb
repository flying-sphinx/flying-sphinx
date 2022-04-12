require "socket"

class LocalPusher
  attr_reader :connections

  def initialize
    @connections = []
    @alive = true
  end

  def start
    Thread.report_on_exception = false
    @server_thread ||= Thread.new do
      socket_server
    end
  end

  def stop
    connections.each(&:close)
    @alive = false
    server_thread.kill
  end

  def send(event, data)
    connections.each do |connection|
      connection.write_json(
        'event'   => event,
        'data'    => data.to_json,
        'channel' => ENV['FLYING_SPHINX_IDENTIFIER']
      )
    end
  end

  private

  attr_reader :server_thread, :alive

  def socket_server
    server = TCPServer.new(
      ENV['FLYING_SPHINX_SOCKETS_HOST'],
      ENV['FLYING_SPHINX_SOCKETS_PORT'].to_i
    )

    loop do
      break unless alive
      connection = LocalPusherConnection.new(server.accept)
      connections << connection

      loop do
        break unless alive
        connection.parse
      end
    end
  rescue Errno::EADDRINUSE
    puts "Socket failure, retrying..."
    sleep 1
    retry
  rescue IOError
    server.close
  end
end
