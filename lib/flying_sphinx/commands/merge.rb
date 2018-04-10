# frozen_string_literal: true

class FlyingSphinx::Commands::Merge < FlyingSphinx::Commands::Base
  def call
    run_action 'merge', index_timeout, merging_options
  end

  private

  def merging_options
    {
      :core_index  => options[:core_index].name,
      :delta_index => options[:delta_index].name,
      :filters     => MultiJson.dump(options[:filters])
    }
  end
end
