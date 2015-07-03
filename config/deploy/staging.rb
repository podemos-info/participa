role :app, %w{capistrano@betaparticipa.podemos.info}
role :web, %w{capistrano@betaparticipa.podemos.info}
role :db,  %w{capistrano@betaparticipa.podemos.info}

set :rvm_ruby_version, '2.2.2'
set :repo_url, 'git@github.com:podemos-info/participa.git'
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
      execute "sudo /etc/init.d/god restart"
    end
  end
end
