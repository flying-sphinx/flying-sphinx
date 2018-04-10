# frozen_string_literal: true

class FlyingSphinx::Commands::Restart < FlyingSphinx::Commands::Base
  def call
    run_action 'restart'
  end
end
