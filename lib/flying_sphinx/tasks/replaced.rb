class FlyingSphinx::Tasks::Replaced
  include Rake::DSL

  def self.call(name, dependencies = [:environment], &block)
    new(name, dependencies, block).call
  end

  def initialize(name, dependencies, block)
    @name = name
    @dependencies = dependencies
    @block = block
  end

  def call
    return unless Rake::Task.task_defined?(name)

    original = Rake::Task[name]
    original.clear

    desc original.comment
    task name => dependencies, &block
  end

  private

  attr_reader :name, :dependencies, :block
end
