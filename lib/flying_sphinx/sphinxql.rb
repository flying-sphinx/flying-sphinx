module FlyingSphinx::SphinxQL
  def self.load
    require 'flying_sphinx/sphinxql/translator'
    require 'flying_sphinx/sphinxql/delayed_delta'
    require 'flying_sphinx/sphinxql/flag_as_deleted_job'

    FlyingSphinx.translator = Translator.new FlyingSphinx::Configuration.new
  end
end
