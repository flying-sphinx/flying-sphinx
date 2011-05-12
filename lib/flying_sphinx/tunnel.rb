class FlyingSphinx::Tunnel
  def self.connect(configuration, &block)
    tunnel = new configuration
    tunnel.open do |session|
      session.loop do
        block.call
      end
    end
  end
  
  def self.required?
    ThinkingSphinx.database_adapter == FlyingSphinx::HerokuSharedAdapter
  end
  
  def initialize(configuration)
    @configuration = configuration
  end

  def open(&block)
    session = Net::SSH.start(@configuration.host, 'sphinx', ssh_options)
    session.forward.remote(
      db_port, db_host, @configuration.database_port, '0.0.0.0'
    )

    session.loop { !remote_exists?(session) }
    
    yield session
  rescue IOError
    # Server closed the connection on us. That's (hopefully) expected, nothing
    # to worry about.
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
