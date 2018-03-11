# frozen_string_literal: true

class FlyingSphinx::Commands::Running < FlyingSphinx::Commands::Base
  def call
    api.get("/running")["running"]
  end
end
