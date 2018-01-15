# frozen_string_literal: true

class FlyingSphinx::Commands::IndexSQL < FlyingSphinx::Commands::Base
  def call
    if async?
      send_action 'index', indexing_options.merge(:unique => 'true')
    else
      clear_jobs

      run_action 'index', index_timeout, indexing_options
    end
  end

  private

  def async?
    indices.any? && !options[:verbose]
  end

  def clear_jobs
    ::Delayed::Job.delete_all(
      "handler LIKE '--- !ruby/object:FlyingSphinx::%'"
    ) if defined?(::Delayed) && ::Delayed::Job.table_exists?
  end

  def indexing_options
    {:indices => indices.join(",")}
  end

  def indices
    options[:indices] || []
  end
end
