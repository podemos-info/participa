role :app, %w{capistrano@juntos.podemos.info}
role :web, %w{capistrano@juntos.podemos.info}
role :db,  %w{capistrano@juntos.podemos.info}

set :branch, :staging
set :deploy_to, '/var/www/betaparticipa.podemos.info'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :start do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging start"
    end
  end
  task :stop do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging stop"
    end
  end
  task :restart do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging restart"
    end
  end
end
