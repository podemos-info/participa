server 'ssh.encomu.cat', user: 'participa', port: 22016, roles: %w(db web app)

set :branch, ENV['BRANCH'] || :master
set :deploy_to, '/home/participa/betaparticipa.barcelonaencomu.cat'
