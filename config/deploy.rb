require 'capistrano/ext/multistage'
require 'config/capistrano_settings'
require 'bundler/capistrano'
require 'erb'

set :application, "s3_cleanser"
set :deploy_to, "/srv/apps/#{application}"

set :scm, :git
set :branch, "master"     # change if you want to deploy to another branch
set :deploy_via, :checkout  # export, checkout, remote_cache
set :keep_releases, 5     # number of releases to keep on server
set :repository,  "git@github.com:VideofyMe/s3_cleanser.git"

default_run_options[:pty] = true

after 'deploy:update', 'deploy:cleanup'