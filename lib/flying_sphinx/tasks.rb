namespace :fs do
  task :index => :environment do
    FlyingSphinx::CLI.new('setup').run
  end

  task :start => :environment do
    FlyingSphinx::CLI.new('start').run
  end

  task :stop  => :environment do
    FlyingSphinx::CLI.new('stop').run
  end

  task :restart => :environment do
    FlyingSphinx::CLI.new('restart').run
  end

  task :rebuild => :environment do
    FlyingSphinx::CLI.new('rebuild').run
  end

  task :index_log => :environment do
    FlyingSphinx::IndexRequest.output_last_index
  end
end
