require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina_sidekiq/tasks'


set :domain, '54.200.115.199'
set :deploy_to, '/www/production'
set :repository, 'https://github.com/pratik14/robotic_web.git'
set :branch, 'master'
set :user, 'deploy'


set :shared_paths, ['config/application.yml', 'log']


task :environment do
  invoke :'rvm:use[ruby-2.3.0@default]'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]

  # sidekiq needs a place to store its pid file and log file
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/pids/"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/pids"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
  end
  deploy do
    # stop accepting new workers
    invoke :'sidekiq:quiet'

    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      invoke :'sidekiq:restart'
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
