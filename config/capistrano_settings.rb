# 
# = Capistrano settings.yml task, info about original code:
#
# Provides a couple of tasks for creating the database.yml 
# configuration file dynamically when deploy:setup is run.
#
# Category::    Capistrano
# Package::     Database
# Author::      Simone Carletti <weppos@weppos.net>
# Copyright::   2007-2010 The Authors
# License::     MIT License
# Link::        http://www.simonecarletti.com/
# Source::      http://gist.github.com/2769
#
#

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :db do

      desc <<-DESC
        Creates the settings.yml configuration file in shared path.

        When this recipe is loaded, db:setup is automatically configured \
        to be invoked after deploy:setup. You can skip this task setting \
        the variable :skip_db_setup to true. This is especially useful \ 
        if you are using this recipe in combination with \
        capistrano-ext/multistaging to avoid multiple db:setup calls \ 
        when running deploy:setup for all stages one by one.
      DESC
      task :setup, :except => { :no_release => true } do

        settings    = { }
        
        settings[:aws_access_key_id]      = Capistrano::CLI.ui.ask("Amazon AWS Access Key Id: ")
        settings[:aws_secret_access_key]  = Capistrano::CLI.ui.ask("Amazon AWS Secret Access Key: ")
        settings[:aws_default_host]       = Capistrano::CLI.ui.ask("Amazon AWS default host: ")
        
        # Create dir in shared_path
        run "mkdir -p #{shared_path}/config"
        
        # Load template, replace variables and store the file
        template = ERB.new(File.read(File.dirname(__FILE__) + '/settings.yml.erb'))
        put template.result(binding), "#{shared_path}/config/settings.yml"
        
      end

      desc <<-DESC
        [internal] Updates the symlink for settings.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml" 
      end

    end

    after "deploy:correct_permissions", "deploy:db:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "deploy:db:symlink"

  end

end
