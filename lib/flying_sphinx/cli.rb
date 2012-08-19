class FlyingSphinx::CLI
  COMMANDS = {
    'configure' => [:configure],
    'index'     => [:index],
    'setup'     => [:configure, :index],
    'start'     => [:start],
    'stop'      => [:stop],
    'restart'   => [:stop, :start],
    'rebuild'   => [:stop, :index, :start]
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
      FlyingSphinx::SphinxConfiguration.new.upload_to configuration.api
      FlyingSphinx::SettingFiles.new.upload_to configuration.api
    else
      FlyingSphinx::SphinxConfiguration.new.upload_file_to configuration.api,
        @arguments.first
    end

    puts "Sent configuration to Sphinx"
    true
  end

  def index
    FlyingSphinx::IndexRequest.cancel_jobs

    request = FlyingSphinx::IndexRequest.new @arguments
    request.index
    puts request.status_message

    true
  end

  def start
    if configuration.start_sphinx
      puts "Started Sphinx"
      true
    else
      puts "Sphinx failed to start... have you indexed first?"
      false
    end
  end

  def stop
    configuration.stop_sphinx
    puts "Stopped Sphinx"
    true
  end
end
