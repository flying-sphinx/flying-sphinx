class FlyingSphinx::CLI
  COMMANDS = {
    'configure' => [:configure],
    'index'     => [:index],
    'setup'     => [:configure, :index],
    'start'     => [:start],
    'stop'      => [:stop],
    'restart'   => [:stop, :start],
    'rebuild'   => [:stop, :configure, :index, :start]
  }

  def initialize(command, arguments = [])
    @command, @arguments = command, arguments
  end

  def run
    methods = COMMANDS[@command]
    raise "Unknown command #{@command}" if methods.nil?

    methods.all? { |method| send method }
  end

  private

  def configuration
    @configuration ||= FlyingSphinx::Configuration.new
  end

  def configure
    if @arguments.empty?
      load_rails
      FlyingSphinx::SphinxConfiguration.new.upload_to configuration.api
      FlyingSphinx::SettingFiles.new.upload_to configuration.api
    else
      FlyingSphinx::SphinxConfiguration.new.upload_file_to configuration.api,
        @arguments.first
    end

    puts "Sent configuration to Sphinx"
    true
  end

  def controller
    @controller ||= FlyingSphinx::Controller.new configuration.api
  end

  def index
    indices = @arguments + [{:verbose => true}]
    controller.index *indices
  end

  def load_rails
    return unless ENV['RAILS_ENV']

    require File.expand_path('config/boot', Dir.pwd)
    require File.expand_path('config/application', Dir.pwd)
    Rails.application.require_environment!

    require 'flying_sphinx/delayed_delta'
  end

  def start
    controller.start
  end

  def stop
    controller.stop
  end
end
