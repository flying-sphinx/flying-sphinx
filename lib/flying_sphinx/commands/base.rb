# frozen_string_literal: true

class FlyingSphinx::Commands::Base < ThinkingSphinx::Commands::Base
  DEFAULT_TIMEOUT = 60

  def call_with_handling
    call
  rescue FlyingSphinx::Error => error
    handle_failure error.command_result
  end

  private

  def api
    @api ||= options[:api] || FlyingSphinx::Configuration.new.api
  end

  def run_action(action, timeout = DEFAULT_TIMEOUT, parameters = {})
    FlyingSphinx.logger.info "Executing Action: #{action}"
    FlyingSphinx::Action.perform api.identifier, timeout do
      send_action action, parameters
    end
    FlyingSphinx.logger.info "Action Finished: #{action}"
  end

  def run_action_with_path(action, timeout = DEFAULT_TIMEOUT)
    path = FlyingSphinx::Configurer.call api

    run_action action, timeout, :path => path
  end

  def send_action(action, parameters = {})
    api.post '/perform', parameters.merge(:action => action)
  end
end
