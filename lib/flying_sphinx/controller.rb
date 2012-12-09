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
    change 'starting', 'started'
  end

  def stop
    change 'stopping', 'stopped'
  end

  private

  attr_reader :api

  def change(initial, expected)
    api.post(initial)

    response = api.get('daemon')
    while response.body.status == initial
      sleep 0.5
      response = api.get('daemon')
    end

    response.body.status == expected
  end
end
