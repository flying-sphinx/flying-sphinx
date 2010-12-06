class FlyingSphinx::Configuration
  attr_reader :heroku_id, :api_key, :host, :port
  
  def initialize(heroku_id, api_key)
    @heroku_id = heroku_id
    @api_key   = api_key
    
    set_from_server
  end
  
  private
  
  def set_from_server
    body = FlyingSphinx::API.new(api_key).get('/app', :heroku_id => heroku_id)
    json = JSON.parse(body)
    
    @host = json['server']
    @port = json['port']
  end
end
