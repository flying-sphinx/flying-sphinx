module FlyingSphinx::Binary
  def self.load
    require 'flying_sphinx/binary/translator'
    require 'flying_sphinx/binary/delayed_delta'
    require 'flying_sphinx/binary/flag_as_deleted_job'
    require 'flying_sphinx/binary/index_job'

    FlyingSphinx.translator = Translator.new FlyingSphinx::Configuration.new
  end
end
