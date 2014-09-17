role :app, %w{capistrano@juntos.podemos.info}
role :web, %w{capistrano@juntos.podemos.info}
role :db,  %w{capistrano@juntos.podemos.info}

set :branch, :staging
set :deploy_to, '/var/www/beta.juntos.podemos.info'
