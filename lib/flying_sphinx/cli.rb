class FlyingSphinx::CLI
  COMMANDS = {
    'configure'  => "ts:configure",
    'index'      => "ts:index",
    'setup'      => "ts:index",
    'start'      => "ts:start",
    'stop'       => "ts:stop",
    'restart'    => "ts:restart",
    'rebuild'    => "ts:rebuild",
    'regenerate' => "ts:rebuild"
  }

  def initialize(command, arguments = [])
    @command, @arguments = command, arguments
  end

  def run
    task = COMMANDS[@command]
    raise "Unknown command #{@command}" if task.nil?

    puts <<-MESSAGE
The flying_sphinx CLI tool is now deprecated. Please use the standard Thinking
Sphinx tasks instead. (Thinking Sphinx tasks will now invoke the appropriate
behaviour for both local and Flying Sphinx environments). In this case:

    heroku run rake #{task}
    MESSAGE
  end
end
