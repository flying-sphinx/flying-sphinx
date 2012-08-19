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

  def self.output_last_index
    index = FlyingSphinx::Configuration.new.api.get('indices/last').body
    puts "Index Job Status: #{index.status}"
    puts "Index Log:\n#{index.log}"
  end

  def initialize(indices = [])
    @indices = indices
  end

  # Shows index name in Delayed::Job#name.
  #
  def display_name
    "#{self.class.name} for #{indices.join(', ')}"
  end

  def index
    begin_request
    while !request_complete?
      sleep 3
    end
  end

  def status_message
    raise "Index Request failed to start. Something's not right!" if @index_id.nil?

    status = request_status
    case status
    when 'FINISHED'
      "Index Request has completed:\n#{request_log}"
    when 'FAILED'
      'Index Request failed.'
    when 'PENDING'
      'Index Request is still pending - something has gone wrong.'
    else
      "Unknown index response: '#{status}'."
    end
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

  def begin_request
    response = api.post 'indices', :indices => indices.join(',')

    @index_id = response.body.id
    @request_begun = true

    raise RuntimeError, 'Your account does not support delta indexing. Upgrading plans is probably the best way around this.' if response.body.status == 'BLOCKED'
  end

  def request_begun?
    @request_begun
  end

  def request_complete?
    case request_status
    when 'FINISHED', 'FAILED'
      true
    when 'PENDING'
      false
    else
      raise "Unknown index response: '#{response.body}'"
    end
  end

  def request_log
    @request.log
  end

  def request_status
    @request = api.get("indices/#{index_id}").body
    @request.status
  end

  def api
    configuration.api
  end
end
