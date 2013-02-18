class FlyingSphinx::Configuration
  attr_reader :host, :port, :ssh_server, :database_port

  def initialize(identifier = nil, api_key = nil)
    @identifier = identifier || identifier_from_env
    @api_key    = api_key    || api_key_from_env

    set_from_server
  end

  def api
    @api ||= FlyingSphinx::API.new(identifier, api_key)
  end

  def start_sphinx
    change 'starting', 'started'
  end

  def stop_sphinx
    change 'stopping', 'stopped'
  end

  def client_key
    "#{identifier}:#{api_key}"
  end

  def output_recent_actions
    api.get('actions').body.each do |action|
      puts "#{action.created_at}  #{action.name}"
    end
  end

  private

  attr_reader :identifier, :api_key

  def change(initial, expected)
    api.post(initial)

    response = api.get('daemon')
    while response.body.status == initial
      sleep 0.5
      response = api.get('daemon')
    end

    response.body.status == expected
  end

  def set_from_server
    response = api.get '/'
    raise 'Invalid Flying Sphinx credentials' if response.status == 403

    @host          = response.body.server
    @port          = response.body.port
    @ssh_server    = response.body.ssh_server
    @database_port = response.body.database_port
  rescue
    # If the central Flying Sphinx server is down, let's use the environment
    # variables so searching is still going to work.
    @host = host_from_env
    @port = port_from_env
  end

  def identifier_from_env
    ENV['STAGED_SPHINX_IDENTIFIER'] || ENV['FLYING_SPHINX_IDENTIFIER']
  end

  def api_key_from_env
    ENV['STAGED_SPHINX_API_KEY'] || ENV['FLYING_SPHINX_API_KEY']
  end

  def host_from_env
    (ENV['STAGED_SPHINX_HOST'] || ENV['FLYING_SPHINX_HOST'] || '').dup
  end

  def port_from_env
    (ENV['STAGED_SPHINX_PORT'] || ENV['FLYING_SPHINX_PORT'] || '9306').dup
  end
end
