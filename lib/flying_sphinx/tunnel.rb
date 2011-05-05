class FlyingSphinx::Tunnel
  def self.connect(configuration, &block)
    tunnel = new configuration
    tunnel.open do |session|
      session.loop &block
    end
  end

  def initialize(configuration)
    @configuration = configuration
  end

  def open(&block)
    Net::SSH.start(@configuration.host, 'sphinx', ssh_options) do |session|
      session.forward.remote(
        db_port, db_host, @configuration.database_port, '0.0.0.0'
      )

      session.open_channel do |channel|
        channel.on_data do |ch, data|
          puts "got stdout: #{data}"
        end
      end

      session.loop { !remote_exists?(session) }

      yield session
    end
  end

  private

  def db_host
    db_config[:host]
  end

  def db_port
    db_config[:port]
  end

  def db_config
    @db_config ||= ActiveRecord::Base.connection.instance_variable_get(:@config)
  end

  def ssh_options
    {:keys => [
      File.expand_path('../../../keys/key', __FILE__)
    ]}
  end

  def remote_exists?(session)
    session.forward.active_remotes.include?(
      [@configuration.database_port, '0.0.0.0']
    )
  end
end
