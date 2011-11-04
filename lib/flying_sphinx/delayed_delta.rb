class FlyingSphinx::DelayedDelta < ThinkingSphinx::Deltas::DefaultDelta
  # Adds a job to the queue, if it doesn't already exist. This is to ensure
  # multiple indexing requests for the same delta index don't get added, as the
  # index only needs to be processed once.
  #
  # Because indexing jobs are all the same object, they all get serialised to
  # the same YAML value.
  #
  # @param [Object] object The job, which must respond to the #perform method.
  #
  def self.enqueue_unless_duplicates(object)
    return if Delayed::Job.where(
      :handler   => object.to_yaml,
      :locked_at => nil
    ).count > 0

    Delayed::Job.enqueue object, :priority => priority
  end

  def self.priority
    ThinkingSphinx::Configuration.instance.settings['delayed_job_priority'] || 0
  end

  def delete(index, instance)
    Delayed::Job.enqueue(
      FlyingSphinx::FlagAsDeletedJob.new(
        index.name, index.document_id_for_key(instance.id)
      ), :priority => self.class.priority
    )
  end

  # Adds a job to the queue for processing the given model's delta index.
  #
  # @param [Class] index the Thinking Sphinx index object.
  #
  def index(index)
    self.class.enqueue_unless_duplicates(
      FlyingSphinx::IndexRequest.new(index.name, true)
    )
  end
end
