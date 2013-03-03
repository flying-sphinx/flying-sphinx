class FlyingSphinx::IndexJob
  attr_accessor :indices

  def initialize(indices)
    @indices = indices
  end

  def perform
    configuration = FlyingSphinx::Configuration.new
    controller    = FlyingSphinx::Controller.new configuration.api

    controller.index *indices

    true
  end
end
