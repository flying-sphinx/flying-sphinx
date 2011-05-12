namespace :fs do
  task :index => :environment do
    puts "Starting Index Request"
    FlyingSphinx::IndexRequest.cancel_jobs
    request = FlyingSphinx::IndexRequest.new
    request.update_and_index
    puts request.status_message
    
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
  
  task :index_log => :environment do
    FlyingSphinx::IndexRequest.output_last_index
  end
  
  task :actions => :environment do
    FlyingSphinx::Configuration.new.output_recent_actions
  end
end
