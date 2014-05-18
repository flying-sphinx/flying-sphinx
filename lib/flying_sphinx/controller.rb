class FlyingSphinx::Controller
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

  def configure(contents = nil)
    upload_configuration contents
    run_action 'configure'
  end

  def index(*indices)
    options = indices.last.is_a?(Hash) ? indices.pop : {}
    async   = indices.any? && !options[:verbose]
    options[:indices] = indices.join(',')

    if async
      send_action 'index_async', options
    else
      ThinkingSphinx.before_index_hooks.each { |hook| hook.call }

      run_action 'index', self.class.index_timeout, options
    end

    true
  end

  def rebuild
    upload_configuration
    run_action 'rebuild', self.class.index_timeout
  end

  def regenerate(contents = nil)
    reset contents

    ThinkingSphinx::RakeInterface.new.generate
  end

  def reset(contents = nil)
    upload_configuration contents
    run_action 'reset'
  end

  def restart
    run_action 'restart'
  end

  def rotate
    run_action 'rotate'
  end

  def sphinx_version
    '2.0.9'
  end

  def start(options = {})
    run_action 'start'
  end

  def stop
    run_action 'stop'
  end

  private

  attr_reader :api

  def upload_configuration(contents = nil)
    FlyingSphinx::Configure.new(contents).call
  end

  def run_action(action, timeout = 60, parameters = {})
    FlyingSphinx::Action.perform(api.identifier, timeout) do
      send_action action, parameters
    end
  end

  def send_action(action, parameters = {})
    api.post '/perform', parameters.merge(:action => action)
  end
end
