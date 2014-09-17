role :app, %w{capistrano@juntos.podemos.info}
role :web, %w{capistrano@juntos.podemos.info}
role :db,  %w{capistrano@juntos.podemos.info}

set :branch, :production
set :deploy_to, '/var/www/juntos.podemos.info'
