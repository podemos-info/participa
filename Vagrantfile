# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.provision :shell, :path => "bin/bootstrap.sh"

  # Required for NFS to work, pick any local IP
  config.vm.network :private_network, ip: '192.168.50.50'
  config.vm.network :forwarded_port, guest: 3000, host: 8080
  config.vm.network :forwarded_port, guest: 1080, host: 8081

  # Use NFS for shared folders for better performance
  config.vm.synced_folder '.', '/vagrant', nfs: true
end
