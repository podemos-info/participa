role :app, %w{capistrano@microcreditos.lamorada.org}
role :web, %w{capistrano@microcreditos.lamorada.org}
role :db,  %w{capistrano@microcreditos.lamorada.org}

set :rvm_ruby_version, '2.2.2'
set :repo_url, 'git@github.com:podemos-info/participa.git'
set :branch, :lamorada
set :rails_env, :production
set :deploy_to, '/var/www/microcreditos.lamorada.org'

after 'deploy:publishing', 'passenger:restart'
  
