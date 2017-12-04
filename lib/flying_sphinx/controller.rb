class FlyingSphinx::Controller
  DEFAULT_TIMEOUT = 60
  @index_timeout = 60 * 60 * 3 # 3 hours

  # For backwards compatibility. These aren't actually used here.
  attr_accessor :path, :bin_path, :searchd_binary_name, :indexer_binary_name

  def self.index_timeout
    @index_timeout
  end

  def self.index_timeout=(index_timeout)
    @index_timeout = index_timeout
  end

  def initialize(api)
    @api = api
  end

  def configure(file = nil)
    options = file.nil? ? FlyingSphinx::ConfigurationOptions.new.to_hash :
      {:configuration => {'sphinx' => file}, :sphinx_version => '2.0.6'}

    run_action 'configure', DEFAULT_TIMEOUT, options
  end

  def index(*indices)
    options = indices.last.is_a?(Hash) ? indices.pop : {}
    async   = indices.any? && !options[:verbose]
    options[:indices] = indices.join(',')

    if async
      send_action 'index', options.merge('unique' => true)
    else
      ::Delayed::Job.delete_all(
        "handler LIKE '--- !ruby/object:FlyingSphinx::%'"
      ) if defined?(::Delayed) && ::Delayed::Job.table_exists?

      run_action 'index', self.class.index_timeout, options
    end

    true
  end

  def rebuild
    run_action 'rebuild', self.class.index_timeout,
      FlyingSphinx::ConfigurationOptions.new.to_hash
  end

  def regenerate(file = nil)
    reset file

    ThinkingSphinx::RakeInterface.new.generate
  end

  def reset(file = nil)
    options = file.nil? ? FlyingSphinx::ConfigurationOptions.new.to_hash :
      {:configuration => {'sphinx' => file}, :sphinx_version => '2.0.6'}

    run_action 'reset', DEFAULT_TIMEOUT, options
  end

  def restart
    run_action 'restart'
  end

  def rotate
    run_action 'rotate'
  end

  def running?
    true
  end

  def sphinx_version
    '2.0.4'
  end

  def start(options = {})
    run_action 'start'
  end

  def stop
    run_action 'stop'
  end

  private

  attr_reader :api

  def run_action(action, timeout = DEFAULT_TIMEOUT, parameters = {})
    FlyingSphinx::Action.perform api.identifier, timeout do
      send_action action, parameters
    end
  end

  def send_action(action, parameters = {})
    api.post '/perform', parameters.merge(:action => action)
  end
end
