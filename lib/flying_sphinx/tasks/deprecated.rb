class FlyingSphinx::Tasks::Deprecated
  include Rake::DSL

  def self.call(old_name, new_name = nil)
    new(old_name, new_name || old_name).call
  end

  def initialize(old_name, new_name)
    @old_name = old_name
    @new_name = new_name
  end

  def call
    namespace :fs do
      desc "Deprecated: Use ts:#{new_name} instead."
      task old_name do
        puts <<-MESSAGE
The task fs:#{old_name} is now deprecated. Please use the standard Thinking
Sphinx task instead: ts:#{new_name} (Thinking Sphinx tasks will now invoke the
appropriate behaviour for both local and Flying Sphinx environments).
        MESSAGE

        Rake::Task["ts:#{new_name}"].invoke
      end
    end
  end

  private

  attr_reader :old_name, :new_name
end
