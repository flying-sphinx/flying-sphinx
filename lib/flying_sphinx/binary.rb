module FlyingSphinx::Binary
  def self.load
    require 'flying_sphinx/binary/translator'

    FlyingSphinx.translator = Translator.new FlyingSphinx::Configuration.new
  end
end
