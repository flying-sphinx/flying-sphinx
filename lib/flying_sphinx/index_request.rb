class FlyingSphinx::IndexRequest
  attr_reader :index_id, :indices

  INDEX_COMPLETE_CHECKING_INTERVAL = 10

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

      !request_complete?
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
    return false unless check_if_request_complete?

    response = api.get("indices/#{index_id}")

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
end
