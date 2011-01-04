class FlyingSphinx::IndexRequest
  attr_reader :index_id, :indices
  
  # Remove all Delta jobs from the queue. If the
  # delayed_jobs table does not exist, this method will do nothing.
  # 
  def self.cancel_jobs
    return unless ::Delayed::Job.table_exists?
    
    ::Delayed::Job.delete_all "handler LIKE '--- !ruby/object:FlyingSphinx::%'"
  end
  
  def initialize(indices = [])
    @indices = indices
  end
  
  # Shows index name in Delayed::Job#name.
  # 
  def display_name
    "#{self.class.name} for #{indices.join(', ')}"
  end
  
  def update_and_index
    update_sphinx_configuration
    index
  end
  
  # Runs Sphinx's indexer tool to process the index. Currently assumes Sphinx is
  # running.
  # 
  # @return [Boolean] true
  # 
  def perform
    index
    true
  end
  
  private
  
  def configuration
    @configuration ||= FlyingSphinx::Configuration.new
  end
  
  def update_sphinx_configuration
    api.put '/app', :configuration => configuration.sphinx_configuration
  end
  
  def index
    FlyingSphinx::Tunnel.connect(configuration) do
      begin_request unless request_begun?
      
      !request_complete?
    end
  rescue Net::SSH::Exception
    cancel_request
  end
  
  def begin_request
    @index_id      = api.post('/app/indices', :indices => indices.join(','))
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
  
  def cancel_request
    return if index_id.nil?
    
    api.put "/app/indices/#{index_id}", :status => 'CANCELLED'
  end
  
  def api
    configuration.api
  end
end
