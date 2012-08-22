role :app, ""

##############################################################################
## SSH
set :user, ""
set :ssh_options, {
  :forward_agent => true,
  :keys => ["#{ENV['HOME']}/.ssh/NAME_OF_KEY_FILE"]
}
##
##############################################################################

after 'deploy:setup', 'deploy:correct_permissions'

namespace :deploy do
  desc "Correct permissions"
  task :correct_permissions do
    sudo "chown -R ubuntu:ubuntu /srv/apps/#{application}"
  end
end