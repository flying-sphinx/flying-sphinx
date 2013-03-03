module FlyingSphinx::SphinxQL
  def self.load
    require 'flying_sphinx/sphinxql/translator'

    FlyingSphinx.translator = Translator.new FlyingSphinx::Configuration.new
  end
end
