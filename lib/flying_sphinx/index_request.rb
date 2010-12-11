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
    api.put '/app/update', :configuration => sphinx_configuration
  end
  
  def sphinx_configuration
    ts_config = ThinkingSphinx::Configuration.instance
    ts_config.port    = configuration.port
    ts_config.address = configuration.host
    
    riddle_config = ts_config.configuration
    
    ThinkingSphinx.context.indexed_models.each do |model|
      model = model.constantize
      model.define_indexes
      riddle_config.indexes.concat model.to_riddle
    end
    
    riddle_config.indexes.each do |index|
      index.sources.each do |source|
        source.sql_host = '127.0.0.1'
        source.sql_port = configuration.database_port
      end
    end
    
    riddle_config.render
  end
  
  def begin_request
    @index_id      = api.post('/app/indices')
    @request_begun = true
  end
  
  def request_begun?
    @request_begun
  end
  
  def request_complete?
    api.get("/app/indices/#{index_id}") == 'FINISHED'
  end
  
  def api
    configuration.api
  end
end
