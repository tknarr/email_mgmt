# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "email_mgmt"
set :repo_url, "git@github.com:tknarr/email_mgmt.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/email_mgmt/app"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/master.key", "config/credentials.yml.enc", "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, ".bundle", "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "config/settings"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 3

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# Rails configuration items
set :conditionally_migrate, true
set :migration_role, :app
set :keep_assets, 3

# RVM configuration
set :rvm_type, :user
set :rvm_ruby_version, '2.5.1@email_mgmt'
set :rvm_custom_path, '/home/email_mgmt/.rvm'

set :puma_init_active_record, true
