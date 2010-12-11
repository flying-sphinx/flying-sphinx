class FlyingSphinx::Configuration
  attr_reader :heroku_id, :api_key, :host, :port, :database_port
  
  def initialize(heroku_id, api_key)
    @heroku_id = heroku_id
    @api_key   = api_key
    
    set_from_server
  end
  
  def api
    @api ||= FlyingSphinx::API.new(heroku_id, api_key)
  end
  
  private
  
  def set_from_server
    json = JSON.parse api.get('/app').body
    
    @host          = json['server']
    @port          = json['port']
    @database_port = json['database_port']
  end
end
