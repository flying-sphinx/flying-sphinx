class FlyingSphinx::Binary::Translator
  def initialize(configuration)
    ThinkingSphinx.remote_sphinx = true

    thinking_sphinx.controller = FlyingSphinx::Controller.new configuration.api
    thinking_sphinx.address    = configuration.host
    thinking_sphinx.port       = configuration.port
    thinking_sphinx.configuration.searchd.client_key =
      configuration.client_key

    if ENV['DATABASE_URL'] && ENV['DATABASE_URL'][/^mysql/].nil?
      ThinkingSphinx.database_adapter = Class.new(ThinkingSphinx::PostgreSQLAdapter) do
        def setup
          create_array_accum_function
        end
      end
    end
  end

  def sphinx_configuration
    @sphinx_configuration ||= begin
      generate_configuration
      thinking_sphinx.configuration.searchd.client_key =
        FlyingSphinx::Configuration.new.client_key
      thinking_sphinx.configuration.render
    end
  end

  def sphinx_indices
    @sphinx_indices ||= begin
      generate_configuration
      thinking_sphinx.configuration.indices
    end
  end

  private

  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end

  def generate_configuration
    return if @generated_configuration

    thinking_sphinx.generate
    @generated_configuration = true
  end
end
