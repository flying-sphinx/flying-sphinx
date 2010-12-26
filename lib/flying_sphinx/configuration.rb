class FlyingSphinx::Configuration
  attr_reader :heroku_id, :api_key, :host, :port, :database_port
  
  def initialize(heroku_id = nil, api_key = nil)
    @heroku_id = heroku_id || heroku_id_from_env
    @api_key   = api_key   || api_key_from_env
    
    set_from_server
    setup_environment_settings
  end
  
  def api
    @api ||= FlyingSphinx::API.new(heroku_id, api_key)
  end
  
  def app_name
    @app_name = heroku_id.split('@').first
  end
  
  def sphinx_configuration
    thinking_sphinx.generate
    set_database_settings
    
    riddle.render
  end
  
  def start_sphinx
    api.post('/app/start')
  end
  
  def stop_sphinx
    api.post('/app/stop')
  end
  
  private
  
  def set_from_server
    json = JSON.parse api.get('/app').body
    
    @host          = json['server']
    @port          = json['port']
    @database_port = json['database_port']
  end
  
  def base_path
    "/mnt/sphinx/flying-sphinx/#{app_name}"
  end
  
  def log_path
    "#{base_path}/log"
  end
  
  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end
  
  def riddle
    thinking_sphinx.configuration
  end
  
  def setup_environment_settings
    ThinkingSphinx.remote_sphinx = true
    
    set_searchd_settings
    set_path_settings
  end
  
  def set_path_settings
    thinking_sphinx.searchd_file_path = "#{base_path}/indexes"
    
    riddle.searchd.pid_file  = "#{base_path}/searchd.pid"
    riddle.searchd.log       = "#{log_path}/searchd.log"
    riddle.searchd.query_log = "#{log_path}/searchd.query.log"
  end
  
  def set_searchd_settings
    thinking_sphinx.port    = port
    thinking_sphinx.address = host
  end
  
  def set_database_settings
    riddle.indexes.each do |index|
      next unless index.respond_to?(:sources)
      
      index.sources.each do |source|
        source.sql_host = '127.0.0.1'
        source.sql_port = database_port
      end
    end
  end
  
  def heroku_id_from_env
    ENV['APP_NAME'] + '@heroku.com'
  end
  
  def api_key_from_env
    ENV['FLYING_SPHINX_API_KEY']
  end
end
