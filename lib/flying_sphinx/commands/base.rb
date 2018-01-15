# frozen_string_literal: true

class FlyingSphinx::Commands::Base < ThinkingSphinx::Commands::Base
  DEFAULT_TIMEOUT = 60
  INDEX_TIMEOUT   = 60 * 60 * 3 # 3 hours

  def call_with_handling
    call
  rescue FlyingSphinx::Error => error
    handle_failure error.command_result
  end

  private

  def api
    @api ||= options[:api] || FlyingSphinx::Configuration.new.api
  end

  def flying_sphinx_settings
    configuration.settings.fetch("flying_sphinx", {})
  end

  def index_timeout
    flying_sphinx_settings["index_timeout"] || INDEX_TIMEOUT
  end

  def run_action(action, timeout = default_timeout, parameters = {})
    FlyingSphinx.logger.info "Executing Action: #{action}"
    FlyingSphinx::Action.perform api.identifier, timeout do
      send_action action, parameters
    end
    FlyingSphinx.logger.info "Action Finished: #{action}"
  end

  def run_action_with_path(action, timeout = default_timeout)
    path = FlyingSphinx::Configurer.call api

    run_action action, timeout, :path => path
  end

  def send_action(action, parameters = {})
    api.post '/perform', parameters.merge(:action => action)
  end

  def default_timeout
    flying_sphinx_settings["timeout"] || DEFAULT_TIMEOUT
  end
end
