require "websocket/driver"

class LocalPusherConnection
  def initialize(socket)
    @socket = socket

    driver.on :connect, -> (event) do
      driver.start
      write_json(
        'event' => 'pusher:connection_established',
        'data'  => {'socket_id' => 101}.to_json
      )
    end
  end

  def close
    socket.close
  end

  def parse
    driver.parse(socket.gets)
  end

  def write(string)
    socket.write(string)
  end

  def write_json(object)
    driver.text(object.to_json)
  end

  private

  attr_reader :socket

  def driver
    @driver ||= WebSocket::Driver.server(self)
  end
end
