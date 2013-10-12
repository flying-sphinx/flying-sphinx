namespace :fs do
  desc "Upload Sphinx configuration and process indices"
  task :index => :environment do
    FlyingSphinx::CLI.new('setup').run
  end

  desc "Start the Sphinx daemon on Flying Sphinx servers"
  task :start => :environment do
    FlyingSphinx::CLI.new('start').run
  end

  desc "Stop the Sphinx daemon on Flying Sphinx servers"
  task :stop  => :environment do
    FlyingSphinx::CLI.new('stop').run
  end

  desc "Restart the Sphinx daemon on Flying Sphinx servers"
  task :restart => :environment do
    FlyingSphinx::CLI.new('restart').run
  end

  desc "Stop, configure, index and then start Sphinx"
  task :rebuild => :environment do
    FlyingSphinx::CLI.new('rebuild').run
  end

  desc "Stop, clear, configure, start then populate Sphinx"
  task :regenerate => :environment do
    FlyingSphinx::CLI.new('rebuild').regenerate
  end
end
