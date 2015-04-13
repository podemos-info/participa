role :app, %w{capistrano@participa.podemos.info}
role :web, %w{capistrano@participa.podemos.info}
role :db,  %w{capistrano@participa.podemos.info}

set :branch, :production
set :deploy_to, '/var/www/participa.podemos.info'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :start do
    on roles(:app) do
      execute "/etc/init.d/unicorn_production start"
      execute "sudo /etc/init.d/god start"
    end
  end
  task :stop do
    on roles(:app) do
      execute "/etc/init.d/unicorn_production stop"
      execute "sudo /etc/init.d/god stop"
    end
  end
  task :restart do
    on roles(:app) do
      execute "/etc/init.d/unicorn_production restart"
      execute "sudo /etc/init.d/god restart"
    end
  end
end
