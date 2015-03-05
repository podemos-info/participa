role :app, %w{capistrano@betaparticipa.podemos.info}
role :web, %w{capistrano@betaparticipa.podemos.info}
role :db,  %w{capistrano@betaparticipa.podemos.info}

set :branch, :staging
set :deploy_to, '/var/www/betaparticipa.podemos.info'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :start do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging start"
      execute "sudo /etc/init.d/god start"
    end
  end
  task :stop do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging stop"
      execute "sudo /etc/init.d/god stop"
    end
  end
  task :restart do
    on roles(:app) do
      execute "/etc/init.d/unicorn_staging restart"
      execute "sudo /etc/init.d/stop restart"
    end
  end
end
