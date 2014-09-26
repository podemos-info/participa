# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'juntos.podemos.info'
set :repo_url, 'gitolite@git.alabs.es:podemos-juntos.git'
set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
