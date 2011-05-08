class FlyingSphinx::IndexRequest
  attr_reader :index_id, :indices

  INDEX_COMPLETE_CHECKING_INTERVAL = 3

  # Remove all Delta jobs from the queue. If the
  # delayed_jobs table does not exist, this method will do nothing.
  #
  def self.cancel_jobs
    return unless defined?(::Delayed) && ::Delayed::Job.table_exists?

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
    api.put('/', :configuration => configuration.sphinx_configuration)
  end

  def index
    FlyingSphinx::Tunnel.connect(configuration) do
      begin_request unless request_begun?

      continue = !request_complete?
      log("Continuing? #{continue}")
      continue
    end
  rescue Net::SSH::Exception
    cancel_request
  rescue RuntimeError => err
    puts err.message
  end

  def begin_request
    response = api.post('indices', :indices => indices.join(','))

    @index_id = response.body
    @request_begun = true

    raise RuntimeError, 'Your account does not support delta indexing. Upgrading plans is probably the best way around this.' if @index_id == 'BLOCKED'
  end

  def request_begun?
    @request_begun
  end

  def request_complete?
    log("request_complete? called")

    return false unless check_if_request_complete?

    log("checking if request is complete")

    response = api.get("indices/#{index_id}")
    
    log("response: '#{response.body}'")

    request_complete_checked!

    case response.body
    when 'FINISHED', 'FAILED'
      puts "Indexing request failed." if response.body == 'FAILED'
      true
    when 'PENDING'
      false
    else
      raise "Unknown index response: '#{response.body}'"
    end
  end

  def request_complete_checked!
    @request_status_last_checked = Time.now
  end

  def check_if_request_complete?
    log("Last Request: #{@request_status_last_checked.inspect}, #{Time.now.inspect}")
    request_complete_checked! unless @request_status_last_checked
    (@request_status_last_checked + INDEX_COMPLETE_CHECKING_INTERVAL) < Time.now
  end

  def cancel_request
    return if index_id.nil?

    puts "Connecting Flying Sphinx to the Database failed"
    puts "Cancelling Index Request..."

    api.put("indices/#{index_id}", :status => 'CANCELLED')
  end

  def api
    configuration.api
  end

  def log(message)
    puts "Index Request : #{message}" if ENV['VERBOSE_LOGGING']
  end
end
