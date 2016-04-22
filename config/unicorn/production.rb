directory = "/srv/rails/participa.barcelonaencomu.cat"

working_directory "#{directory}/current"
pid "#{directory}/current/tmp/pids/unicorn.pid"
stderr_path "#{directory}/shared/log/unicorn.log"
stdout_path "#{directory}/shared/log/unicorn.log"
listen "/tmp/unicorn.participa.barcelonaencomu.cat.sock"
worker_processes 4
timeout 120
