# frozen_string_literal: true

class FlyingSphinx::Commands::Clear < FlyingSphinx::Commands::Base
  def call
    run_action 'clear'
  end
end
