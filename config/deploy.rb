require "bundler/capistrano"

default_run_options[:pty] = true

set  :application, "govsgo.com"
role :app,         application
role :web,         application
role :db,          application, primary: true

set :user,        "deploy"
set :deploy_to,   "/var/apps/govsgo"
set :deploy_via,  :remote_cache
set :use_sudo,    false
set :ssh_options, forward_agent: true

set :scm,        "git"
set :repository, "git@github.com:railsrumble/rr10-team-236.git"
set :branch,     "master"

namespace :deploy do
  desc "Tell Passenger to restart."
  task :restart, :roles => :web do
    run "touch #{deploy_to}/current/tmp/restart.txt" 
  end
  
  desc "Do nothing on startup so we don't get a script/spin error."
  task :start do
    puts "You may need to restart Apache."
  end

  desc "Symlink extra configs and folders."
  task :symlink_extras do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/private.yml #{release_path}/config/private.yml"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"
  end

  desc "Setup shared directory."
  task :setup_shared do
    run "mkdir #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/private.example.yml"), "#{shared_path}/config/private.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  desc "Make sure there is something to deploy"
  task :check_revision, :roles => :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  
  namespace :beanstalk do
    desc "Start the beanstalkd queue server"
    task :start do
      sudo "/etc/init.d/beanstalkd start"
    end

    desc "Stop the beanstalkd queue server"
    task :stop do
      sudo "/etc/init.d/beanstalkd stop"
    end
    
    desc "Start workers"
    task :start_workers do
      sudo "RAILS_ENV=production #{current_path}/script/play_computer_moves"
    end
    
    desc "Stop workers"
    task :stop_workers do
      sudo "RAILS_ENV=production #{current_path}/script/play_computer_moves stop"
    end
    
    desc "Restart workers"
    task :restart_workers do
      sudo "RAILS_ENV=production #{release_path}/script/play_computer_moves stop"
      sudo "RAILS_ENV=production #{release_path}/script/play_computer_moves"
    end
    
    desc "Requeue all games waiting on a computer move"
    task :queue_all_for_computer do
      run "cd #{current_path} && RAILS_ENV=production rake data:game:queue_all_for_computer"
    end
  end
end

before "deploy",             "deploy:check_revision"
after  "deploy",             "deploy:cleanup" # keeps only last 5 releases
after  "deploy:setup",       "deploy:setup_shared"
after  "deploy:update_code", "deploy:symlink_extras"
after  "deploy:restart",     "deploy:beanstalk:restart_workers"
