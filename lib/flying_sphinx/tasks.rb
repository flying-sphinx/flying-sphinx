namespace :fs do
  task :index => :environment do
    puts "Starting Index Request"
    FlyingSphinx::IndexRequest.cancel_jobs
    FlyingSphinx::IndexRequest.new.update_and_index
    puts "Index Request has completed"
  end
  
  task :start => :environment do
    puts "Starting Sphinx..."
    FlyingSphinx::Configuration.new.start_sphinx
    puts "Started Sphinx"
  end
  
  task :stop  => :environment do
    puts "Stopping Sphinx..."
    FlyingSphinx::Configuration.new.stop_sphinx
    puts "Stopped Sphinx"
  end
  
  task :restart => [:environment, :stop, :start]
  task :rebuild => [:environment, :stop, :index, :start]
end
