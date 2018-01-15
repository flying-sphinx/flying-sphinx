module FlyingSphinx
  module Tasks
    #
  end
end

require_relative "tasks/replaced"
require_relative "tasks/deprecated"

# Replaced ts tasks
FlyingSphinx::Tasks::Replaced.call "ts:clear" do
  interface.clear
end

FlyingSphinx::Tasks::Replaced.call "ts:rebuild",
  ["ts:sql:rebuild", "ts:rt:index"]

FlyingSphinx::Tasks::Replaced.call "ts:restart" do
  interface.restart
end

FlyingSphinx::Tasks::Replaced.call "ts:sql:rebuild" do
  interface.rebuild
end

FlyingSphinx::Tasks::Replaced.call "ts:rt:rebuild" do
  interface.reset

  Rake::Task["ts:rt:index"].invoke
end

# Deprecated tasks in the fs namespace
FlyingSphinx::Tasks::Deprecated.call :index
FlyingSphinx::Tasks::Deprecated.call :start
FlyingSphinx::Tasks::Deprecated.call :stop
FlyingSphinx::Tasks::Deprecated.call :restart
FlyingSphinx::Tasks::Deprecated.call :rebuild
FlyingSphinx::Tasks::Deprecated.call :regenerate, :rebuild
