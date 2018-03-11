# frozen_string_literal: true

class FlyingSphinx::Commands::Start < FlyingSphinx::Commands::Base
  def call
    run_action 'start'
  end
end
