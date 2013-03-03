class FlyingSphinx::Controller
  @index_timeout = 60 * 60 * 3 # 3 hours

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
    options = file.nil? ? configuration_options :
      {:configuration => {'sphinx' => file}, :sphinx_version => '2.0.6'}

    FlyingSphinx::Action.perform api.identifier do
      api.put 'configure', options
    end
  end

  def index(*indices)
    options = indices.last.is_a?(Hash) ? indices.pop : {}
    async   = indices.any? && !options[:verbose]
    options[:indices] = indices.join(',')

    if async
      api.post 'indices/unique', options
    else
      FlyingSphinx::IndexRequest.cancel_jobs

      FlyingSphinx::Action.perform api.identifier, self.class.index_timeout do
        api.post 'indices', options
      end
    end

    true
  end

  def rebuild
    FlyingSphinx::Action.perform api.identifier, self.class.index_timeout do
      api.put 'rebuild', configuration_options
    end
  end

  def restart
    FlyingSphinx::Action.perform api.identifier do
      api.post 'restart'
    end
  end

  def start(options = {})
    FlyingSphinx::Action.perform(api.identifier) { api.post 'start' }
  end

  def stop
    FlyingSphinx::Action.perform(api.identifier) { api.post 'stop' }
  end

  private

  attr_reader :api

  def configuration_options
    version       = '2.0.4'
    configuration = ThinkingSphinx::Configuration.instance

    version = configuration.version if configuration.respond_to?(:version)

    {
      :sphinx_version => version,
      :configuration  => FlyingSphinx::SettingFiles.new.to_hash.merge(
        'sphinx' => FlyingSphinx.translator.sphinx_configuration
      )
    }
  end
end
