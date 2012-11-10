class FlyingSphinx::Controller
  def initialize(api)
    @api = api
  end

  def index(*indices)
    options = indices.last.is_a?(Hash) ? indices.pop : {}

    FlyingSphinx::IndexRequest.cancel_jobs

    request = FlyingSphinx::IndexRequest.new indices
    request.index
    puts request.status_message if options[:verbose]

    true
  end

  def start(options = {})
    if api.post('start').success?
      puts "Started Sphinx"
      true
    else
      puts "Sphinx failed to start... have you indexed first?"
      false
    end
  end

  def stop
    api.post('stop').success?
    puts "Stopped Sphinx"
    true
  end

  private

  attr_reader :api
end
