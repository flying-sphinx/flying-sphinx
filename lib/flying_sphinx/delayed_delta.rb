class FlyingSphinx::DelayedDelta < ThinkingSphinx::Deltas::DefaultDelta
  # Adds a job to the queue, if it doesn't already exist. This is to ensure
  # multiple indexing requests for the same delta index don't get added, as the
  # index only needs to be processed once.
  #
  # Because indexing jobs are all the same object, they all get serialised to
  # the same YAML value.
  #
  # @param [Object] object The job, which must respond to the #perform method.
  # @param [Integer] priority (0)
  #
  def self.enqueue(object, priority = 0)
    return if duplicates_exist? object

    enqueue_without_duplicates_check object, priority
  end

  def self.enqueue_without_duplicates_check(object, priority = 0)
    if defined?(Rails) && Rails.version.to_i <= 2
      ::Delayed::Job.enqueue(object, priority)
    else
      ::Delayed::Job.enqueue(object, :priority => priority)
    end
  end

  # Checks whether a given job already exists in the queue.
  #
  # @param [Object] object The job
  # @return [Boolean] True if a duplicate of the job already exists in the queue
  #
  def self.duplicates_exist?(object)
    ::Delayed::Job.count(
      :conditions => {
        :handler    => object.to_yaml,
        :locked_at  => nil
      }
    ) > 0
  end

  # Adds a job to the queue for processing the given model's delta index. A job
  # for hiding the instance in the core index is also created, if an instance is
  # provided.
  #
  # Neither job will be queued if updates or deltas are disabled, or if the
  # instance (when given) is not toggled to be in the delta index. The first two
  # options are controlled via ThinkingSphinx.updates_enabled? and
  # ThinkingSphinx.deltas_enabled?.
  #
  # @param [Class] model the ActiveRecord model to index.
  # @param [ActiveRecord::Base] instance the instance of the given model that
  #   has changed. Optional.
  # @return [Boolean] true
  #
  def index(model, instance = nil)
    return true if skip? instance

    self.class.enqueue(
      FlyingSphinx::IndexRequest.new(model.delta_index_names, true),
      delayed_job_priority
    )

    self.class.enqueue_without_duplicates_check(
      FlyingSphinx::FlagAsDeletedJob.new(
        model.core_index_names, instance.sphinx_document_id
      ),
      delayed_job_priority
    ) if instance

    true
  end

  private

  def delayed_job_priority
    ThinkingSphinx::Configuration.instance.delayed_job_priority
  end

  # Checks whether jobs should be enqueued. Only true if updates and deltas are
  # enabled, and the instance (if there is one) is toggled.
  #
  # @param [ActiveRecord::Base, NilClass] instance
  # @return [Boolean]
  #
  def skip?(instance)
    !ThinkingSphinx.updates_enabled? ||
    !ThinkingSphinx.deltas_enabled?  ||
    (instance && !toggled(instance))
  end
end
