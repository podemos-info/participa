role :app, %w{capistrano@encomupodem.podemos.info}
role :web, %w{capistrano@encomupodem.podemos.info}
role :db,  %w{capistrano@encomupodem.podemos.info}

set :rvm_ruby_version, '2.2.2'
set :repo_url, 'git@github.com:podemos-info/participa.git'
set :branch, :encomupodem
set :rails_env, :production
set :deploy_to, '/var/www/encomupodem.podemos.info'

after 'deploy:publishing', 'passenger:restart'

