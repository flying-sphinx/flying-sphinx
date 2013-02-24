class FlyingSphinx::Binary::Translator
  def initialize(configuration)
    ThinkingSphinx.remote_sphinx = true

    thinking_sphinx.address = configuration.host
    thinking_sphinx.port    = configuration.port
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
      thinking_sphinx.generate
      thinking_sphinx.configuration.searchd.client_key =
        FlyingSphinx::Configuration.new.client_key
      thinking_sphinx.configuration.render
    end
  end

  def sphinx_indices
    thinking_sphinx.configuration.indices
  end

  private

  def thinking_sphinx
    ThinkingSphinx::Configuration.instance
  end
end
