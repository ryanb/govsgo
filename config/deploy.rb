set :application, "govsgo.com"
set :repository,  "set your repository location here"

set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


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

