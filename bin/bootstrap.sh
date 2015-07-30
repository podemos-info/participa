#!/usr/bin/env bash
# http://docs.vagrantup.com/v2/getting-started/provisioning.html

USER=vagrant

sudo apt-get update
sudo apt-get install -y postgresql-9.3 imagemagick redis-server curl git-core libpq-dev build-essential sqlite3 qt5-default libqt5webkit5-dev wkhtmltopdf

rm -rf /usr/local/rvm

cat > /home/vagrant/.gemrc <<EOF
gem: --no-ri --no-rdoc
EOF

# TODO create postgres DB and config/database.yml

cat > /home/vagrant/deploy.sh <<EOF
#!/usr/bin/env bash

set -x

if [ ! -d ~/.rvm ] ; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable 
fi

source ~/.rvm/scripts/rvm
rvm use --install 2.1.2 
ruby --version

cd /vagrant
bundle install

cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml

rake db:migrate
mailcatcher
rails server 
EOF

# TODO: start resque
# TODO: start mailcatcher

chmod +x /home/vagrant/deploy.sh 

su - vagrant -c "/home/vagrant/deploy.sh" 
