require 'flying_sphinx'

if ENV['FLYING_SPHINX_IDENTIFIER'] || ENV['STAGED_SPHINX_IDENTIFIER']
  if ThinkingSphinx::Configuration.instance.respond_to?(:settings)
    FlyingSphinx::SphinxQL.load
  else
    FlyingSphinx::Binary.load
  end
end
