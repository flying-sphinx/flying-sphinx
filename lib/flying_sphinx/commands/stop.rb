# frozen_string_literal: true

class FlyingSphinx::Commands::Stop < FlyingSphinx::Commands::Base
  def call
    run_action 'stop'
  end
end
