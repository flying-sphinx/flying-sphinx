class FlyingSphinx::IndexRequest
  attr_reader :configuration, :index_id
  
  def initialize(configuration)
    @configuration = configuration
    
    update_sphinx_configuration
    
    FlyingSphinx::Tunnel.connect(configuration) do
      begin_request unless request_begun?
      
      !request_complete?
    end
  end
  
  private
  
  def update_sphinx_configuration
    api.put '/app', :configuration => configuration.sphinx_configuration
  end
  
  def begin_request
    @index_id      = api.post('/app/indices')
    @request_begun = true
  end
  
  def request_begun?
    @request_begun
  end
  
  def request_complete?
    case response = api.get("/app/indices/#{index_id}")
    when 'FINISHED', 'FAILED'
      puts "Indexing request failed." if response == 'FAILED'
      true
    when 'PENDING'
      false
    else
      raise "Unknown index response: #{response}"
    end
  end
  
  def api
    configuration.api
  end
end
