# frozen_string_literal: true

class FlyingSphinx::Commands::Base < ThinkingSphinx::Commands::Base
  DEFAULT_TIMEOUT = 60
  INDEX_TIMEOUT   = 60 * 60 * 3 # 3 hours
  ERROR_MESSAGES  = {
    "BLOCKED"      => <<-TXT,
BLOCKED: Single-index processing is not permitted for your plan level
    TXT
    "UNCONFIGURED" => <<-TXT,
UNCONFIGURED: This command can only be run once you have provided your Sphinx
configuration (via the ts:configure or ts:rebuild tasks).
    TXT
    "INVALID PATH" => <<-TXT
INVALID PATH: Something has gone wrong with the uploading of your configuration.
Please contact Flying Sphinx Support: http://support.flying-sphinx.com
    TXT
  }.freeze

  def call_with_handling
    call
  rescue FlyingSphinx::Error => error
    handle_failure error
  end

  private

  def api
    @api ||= options[:api] || FlyingSphinx::Configuration.new.api
  end

  def flying_sphinx_settings
    configuration.settings.fetch("flying_sphinx", {})
  end

  def handle_failure(error)
    stream.puts <<-TXT

The Flying Sphinx command failed:
  Class: #{self.class.name}
  Error: #{error.message}

If everything looks to be in order, please try the command again. If the error
persists, please contact Flying Sphinx Support: http://support.flying-sphinx.com

    TXT

    raise error
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
    response = api.post '/perform', parameters.merge(:action => action)

    if ERROR_MESSAGES.keys.include?(response["status"])
      raise FlyingSphinx::Error, ERROR_MESSAGES[response["status"]]
    end

    if response["status"] != "OK"
      raise FlyingSphinx::Error, "Unknown Exception: #{response["status"]}"
    end

    response
  end

  def default_timeout
    flying_sphinx_settings["timeout"] || DEFAULT_TIMEOUT
  end
end
