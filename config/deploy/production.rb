role :app, %w{deploy@medrando.enmarea.gal}
role :web, %w{deploy@medrando.enmarea.gal}
role :db,  %w{deploy@medrando.enmarea.gal}

set :rvm_ruby_version, '2.2.2'
set :repo_url, 'https://github.com/EnMarea/participa.git'
set :branch, "deploy/mare"
set :deploy_to, '/var/www/participa'

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :start do
    on roles(:app) do
      execute "/var/www/participa/scripts/unicorn_rails start"
    end
  end
  task :stop do
    on roles(:app) do
      execute "/var/www/participa/scripts/unicorn_rails stop"
    end
  end
  task :restart do
    on roles(:app) do
      execute "/var/www/participa/scripts/unicorn_rails restart"
    end
  end
end
