# frozen_string_literal: true

class FlyingSphinx::Commands::Rebuild < FlyingSphinx::Commands::Base
  def call
    run_action_with_path 'rebuild'
  end
end
