# frozen_string_literal: true

class FlyingSphinx::Commands::Reset < FlyingSphinx::Commands::Base
  def call
    run_action_with_path 'reset'
  end
end
