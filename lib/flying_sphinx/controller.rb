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

  def configure(file = nil)
    options = file.nil? ? FlyingSphinx::ConfigurationOptions.new.to_hash :
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
      ::Delayed::Job.delete_all(
        "handler LIKE '--- !ruby/object:FlyingSphinx::%'"
      ) if defined?(::Delayed) && ::Delayed::Job.table_exists?

      FlyingSphinx::Action.perform api.identifier, self.class.index_timeout do
        api.post 'indices', options
      end
    end

    true
  end

  def rebuild
    FlyingSphinx::Action.perform api.identifier, self.class.index_timeout do
      api.put 'rebuild', FlyingSphinx::ConfigurationOptions.new.to_hash
    end
  end

  def regenerate(file = nil)
    reset file

    ThinkingSphinx::RakeInterface.new.generate
  end

  def reset(file = nil)
    options = file.nil? ? FlyingSphinx::ConfigurationOptions.new.to_hash :
      {:configuration => {'sphinx' => file}, :sphinx_version => '2.0.6'}

    FlyingSphinx::Action.perform api.identifier do
      api.put 'reset', options
    end
  end

  def restart
    FlyingSphinx::Action.perform api.identifier do
      api.post 'restart'
    end
  end

  def rotate
    FlyingSphinx::Action.perform api.identifier do
      api.post 'rotate'
    end
  end

  def sphinx_version
    '2.0.4'
  end

  def start(options = {})
    FlyingSphinx::Action.perform(api.identifier) { api.post 'start' }
  end

  def stop
    FlyingSphinx::Action.perform(api.identifier) { api.post 'stop' }
  end

  private

  attr_reader :api
end
