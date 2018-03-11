class FlyingSphinx::RakeInterface < ThinkingSphinx::RakeInterface
  def clear
    command :clear
  end

  def rebuild
    command :rebuild
  end

  def reset
    command :reset
  end

  def restart
    command :restart
  end

  private

  def command(command, extra_options = {})
    ThinkingSphinx::Commander.call(
      command, configuration, options.merge(extra_options)
    )
  end
end
