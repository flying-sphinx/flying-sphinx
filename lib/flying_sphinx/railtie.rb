class FlyingSphinx::Railtie < Rails::Railtie
  rake_tasks do
    load File.expand_path('../tasks.rb', __FILE__)
  end

  initializer "flying_sphinx.set_sphinx_host_and_port" do |app|
    if ThinkingSphinx::Configuration.instance.respond_to?(:settings)
      FlyingSphinx::SphinxQL.load
    else
      FlyingSphinx::Binary.load
    end
  end if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
end
