module FlyingSphinx::Commands
end

require "flying_sphinx/commands/base"
require "flying_sphinx/commands/clear"
require "flying_sphinx/commands/configure"
require "flying_sphinx/commands/index_sql"
require "flying_sphinx/commands/prepare"
require "flying_sphinx/commands/rebuild"
require "flying_sphinx/commands/reset"
require "flying_sphinx/commands/restart"
require "flying_sphinx/commands/rotate"
require "flying_sphinx/commands/running"
require "flying_sphinx/commands/start"
require "flying_sphinx/commands/start_attached"
require "flying_sphinx/commands/stop"

ThinkingSphinx::Commander.registry.merge!(
  :clear           => FlyingSphinx::Commands::Clear,
  :clear_real_time => FlyingSphinx::Commands::Clear,
  :clear_sql       => FlyingSphinx::Commands::Clear,
  :configure       => FlyingSphinx::Commands::Configure,
  :index_sql       => FlyingSphinx::Commands::IndexSQL,
  :prepare         => FlyingSphinx::Commands::Prepare,
  :rebuild         => FlyingSphinx::Commands::Rebuild,
  :reset           => FlyingSphinx::Commands::Reset,
  :restart         => FlyingSphinx::Commands::Restart,
  :rotate          => FlyingSphinx::Commands::Rotate,
  :running         => FlyingSphinx::Commands::Running,
  :start_attached  => FlyingSphinx::Commands::StartAttached,
  :start_detached  => FlyingSphinx::Commands::Start,
  :stop            => FlyingSphinx::Commands::Stop
)
