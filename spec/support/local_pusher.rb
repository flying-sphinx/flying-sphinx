require "socket"

class LocalPusher
  attr_reader :connections

  def initialize
    mutex.synchronize do
      @connections = []
      @alive = true
    end
  end

  def start
    Thread.report_on_exception = false
    @server_thread ||= Thread.new do
      socket_server
    end
  end

  def stop
    mutex.synchronize do
      connections.each(&:close)
      @alive = false
    end

    server_thread.kill
  end

  def send(event, data)
    mutex.synchronize do
      connections.each do |connection|
        connection.write_json(
          'event'   => event,
          'data'    => data.to_json,
          'channel' => ENV['FLYING_SPHINX_IDENTIFIER']
        )
      end
    end
  end

  private

  attr_reader :server_thread, :alive

  def mutex
    @mutex ||= Mutex.new
  end

  def socket_server
    server = TCPServer.new(
      ENV['FLYING_SPHINX_SOCKETS_HOST'],
      ENV['FLYING_SPHINX_SOCKETS_PORT'].to_i
    )

    loop do
      break unless mutex.synchronize { alive }
      connection = LocalPusherConnection.new(server.accept_nonblock)
      mutex.synchronize { connections << connection }

      loop do
        break unless mutex.synchronize { alive }
        connection.parse
      end
    rescue IO::WaitReadable, Errno::EINTR
      IO.select([server])
      retry
    end
  rescue Errno::EADDRINUSE
    puts "Socket failure, retrying..."
    sleep 1
    retry
  ensure
    server.close
  end
end
