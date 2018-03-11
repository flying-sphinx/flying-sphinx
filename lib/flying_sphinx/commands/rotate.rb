# frozen_string_literal: true

class FlyingSphinx::Commands::Rotate < FlyingSphinx::Commands::Base
  def call
    run_action 'rotate'
  end
end
