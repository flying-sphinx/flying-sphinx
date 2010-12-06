namespace :fs do
  task :index => :environment
  
  task :start => :environment
  
  task :stop  => :environment
  
  task :restart => [:environment, :stop, :start]
end
