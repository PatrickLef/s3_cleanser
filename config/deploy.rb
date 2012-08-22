require 'capistrano/ext/multistage'
require 'config/capistrano_settings'
require 'bundler/capistrano'
require 'erb'

set :application, "s3_cleanser"
set :deploy_to, "/srv/apps/#{application}"

set :scm, :git
set :branch, "master"     # change if you want to deploy to another branch
set :deploy_via, :export  # export, checkout, remote_cache
set :keep_releases, 5     # number of releases to keep on server
set :repository,  "git@github.com:VideofyMe/s3_cleanser.git"

after 'deploy:update', 'deploy:cleanup', 'deploy:tag'

namespace :deploy do
  desc "Tag a release"
  task :tag do
    # Ask for tag
    tags = `git tag`.split("\n")
    puts "Latest tag = #{tags.last}"
    message = "Choose a tag to release. Leave this blank to create a new tag automatically..."
    tag = Capistrano::CLI.ui.ask(message)
  
    # Check tag
    if tag.empty?
      tag = Time.now.strftime("%Y%m%d-%H%M")
      `git tag -a #{tag} -m "New tag reated by Capistrano"`
      `git push --tags`
    else
      abort "[ERROR] Tag does not exist. Aborting deploy." unless tags.include?(tag)
    end
    
    set :branch, tag
  end
end