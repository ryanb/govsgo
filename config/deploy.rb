require "bundler/capistrano"

set :application, "govsgo.com"
role :app, application
role :web, application
role :db,  application, :primary => true

set :user, "deploy"
set :deploy_to, "/var/apps/govsgo"
set :deploy_via, :remote_cache
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

set :scm, "git"
set :repository, "git@github.com:railsrumble/rr10-team-236.git"
set :branch, "master"

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
    # run "ln -nfs #{shared_path}/config/app_config.yml #{release_path}/config/app_config.yml"
    # run "ln -nfs #{shared_path}/config/session_secret.txt #{release_path}/config/session_secret.txt"
    # run "ln -nfs #{shared_path}/assets #{release_path}/public/assets"
  end

  desc "Setup shared directory."
  task :setup_shared do
    # run "mkdir #{shared_path}/assets"
    # run "mkdir #{shared_path}/config"
    # run "mkdir #{shared_path}/db"
    # run "mkdir #{shared_path}/db/sphinx"
    # put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    # put File.read("config/app_config.example.yml"), "#{shared_path}/config/app_config.yml"
    # put File.read("config/session_secret.example.txt"), "#{shared_path}/config/session_secret.txt"
    # puts "Now edit the config files and fill assets folder in #{shared_path}."
  end
  
  # desc "Update the crontab file"
  # task :update_crontab, :roles => :db do
  #   run "cd #{release_path} && whenever --update-crontab #{application}"
  # end
  
  desc "Make sure there is something to deploy"
  task :check_revision, :roles => :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
end

before "deploy", "deploy:check_revision"
after "deploy", "deploy:cleanup" # keeps only last 5 releases
after "deploy:setup", "deploy:setup_shared"
after "deploy:update_code", "deploy:symlink_extras"
# after "deploy:symlink", "deploy:update_crontab"
