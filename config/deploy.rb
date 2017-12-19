# config valid only for current version of Capistrano
lock '3.4.1'

set :application, 'shabot'
set :repo_url, 'git@github.com:shallontecbiz/shabot.git'

set :deploy_to, "/home/ec2-user/rails_apps/shabot"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :keep_releases, 3

set :bundle_without,  [:development, :test]

set :user, "ec2-user"
set :group, "ec2-user"

set :rbenv_custom_path, '/usr/local/rbenv'
set :rbenv_type, :system
set :rbenv_ruby, '2.3.6'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

set :default_environment, {
  'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}

set :bundle_binstubs, nil

set :linked_files, fetch(:linked_files, []).push('.env')

set :linked_dirs, %w{log tmp/backup tmp/pids tmp/cache tmp/sockets vendor/bundle}

set :passenger_restart_with_sudo, true
set :passenger_restart_command, 'PATH=$PATH passenger-config restart-app'
 
set :ssh_options, {
  user: 'ec2-user',
  forward_agent: true
}

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5


require 'seed-fu/capistrano3'

before 'deploy:publishing', 'db:seed_fu'
