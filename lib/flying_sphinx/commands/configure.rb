# frozen_string_literal: true

class FlyingSphinx::Commands::Configure < FlyingSphinx::Commands::Base
  def call
    run_action_with_path 'configure'
  end
end
