class FlyingSphinx::API
  include HTTParty
  
  APIServer = 'http://flying-sphinx.com/heroku'
  
  attr_reader :api_key, :heroku_id
  
  def initialize(heroku_id, api_key)
    @api_key   = api_key
    @heroku_id = heroku_id
  end
  
  def get(path, data = {})
    self.class.get "#{APIServer}#{path}", :query => data.merge(api_options)
  end
  
  def post(path, data = {})
    self.class.post "#{APIServer}#{path}", :body => data.merge(api_options)
  end
  
  def put(path, data = {})
    self.class.put "#{APIServer}#{path}", :body => data.merge(api_options)
  end
  
  private
  
  def api_options
    {
      :api_key   => api_key,
      :heroku_id => heroku_id
    }
  end
end
