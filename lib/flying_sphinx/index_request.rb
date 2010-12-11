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
    api.put '/app', :configuration => sphinx_configuration
  end
  
  def sphinx_configuration
    ts_config = ThinkingSphinx::Configuration.instance
    ts_config.port    = configuration.port
    ts_config.address = configuration.host
    
    riddle_config = ts_config.configuration
    
    base_path = "/mnt/sphinx/flying-sphinx/#{app_name}"
    ts_config.searchd_file_path = "#{base_path}/indexes"
    riddle_config.searchd.pid_file = "#{base_path}/searchd.pid"
    riddle_config.searchd.log = "#{base_path}/log/searchd.log"
    riddle_config.searchd.query_log = "#{base_path}/log/searchd.query.log"
    
    riddle_config.indexes.clear
    
    ThinkingSphinx.context.indexed_models.each do |model|
      model = model.constantize
      model.define_indexes
      riddle_config.indexes.concat model.to_riddle
    end
    
    riddle_config.indexes.each do |index|
      next unless index.respond_to?(:sources)
      
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
