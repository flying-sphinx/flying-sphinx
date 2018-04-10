# frozen_string_literal: true

class FlyingSphinx::Commands::StartAttached < FlyingSphinx::Commands::Base
  def call
    stream.puts <<-MESSAGE
It is not possible to start the Sphinx daemon as an attached process. Please
use ts:start without the NODETACH flag set.
    MESSAGE
  end
end
