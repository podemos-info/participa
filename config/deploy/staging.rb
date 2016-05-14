role :app, %w{participa@participa.barcelonaencomu.cat}
role :web, %w{participa@participa.barcelonaencomu.cat}
role :db,  %w{participa@participa.barcelonaencomu.cat}

set :rvm_ruby_version, '2.2.2'
set :branch, ENV['BRANCH'] || :master
set :deploy_to, '/srv/rails/betaparticipa.barcelonaencomu.cat'

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
