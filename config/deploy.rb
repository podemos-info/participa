# config valid only for Capistrano 3.4.0
lock '3.4.0'

set :application, 'participa.podemos.info'
set :repo_url, 'git@github.com:podemos-info/podemos.git'
set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db/podemos}
