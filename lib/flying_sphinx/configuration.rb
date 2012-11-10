class FlyingSphinx::Configuration
  def initialize(identifier = nil, api_key = nil)
    @identifier = identifier || identifier_from_env
    @api_key    = api_key    || api_key_from_env
  end

  def api
    @api ||= FlyingSphinx::API.new(identifier, api_key)
  end

  def host
    @host ||= response_body.server rescue host_from_env
  end

  def output_recent_actions
    api.get('actions').body.each do |action|
      puts "#{action.created_at}  #{action.name}"
    end
  end

  def port
    @port ||= response_body.port rescue port_from_env
  end

  def username
    "#{api_key}#{identifier}"
  end

  private

  attr_reader :identifier, :api_key

  def response_body
    @response_body ||= begin
      response = api.get '/'
      raise 'Invalid Flying Sphinx credentials' if response.status == 403
      response.body
    end
  end

  def identifier_from_env
    ENV['STAGED_SPHINX_IDENTIFIER'] || ENV['FLYING_SPHINX_IDENTIFIER']
  end

  def api_key_from_env
    ENV['STAGED_SPHINX_API_KEY'] || ENV['FLYING_SPHINX_API_KEY']
  end

  def host_from_env
    (ENV['STAGED_SPHINX_HOST'] || ENV['FLYING_SPHINX_HOST']).dup
  end

  def port_from_env
    (ENV['STAGED_SPHINX_PORT'] || ENV['FLYING_SPHINX_PORT']).dup
  end
end
