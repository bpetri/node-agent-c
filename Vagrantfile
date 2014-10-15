# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'
Vagrant.require_version ">= 1.6.0"

$instance_name="celix-node-agent-service-%02d"
$instance_ip="172.17.8.2%02d"
$num_instances = 2

$coreos_channel="coreos-alpha"
#$coreos_version=">= 361.0.0"

$virtualbox_gui = false
$virtualbox_memory = 512
$virtualbox_cpus = 1

Vagrant.configure("2") do |config|


  config.vm.box = $coreos_channel
  config.vm.box_version = $coreos_version
  config.vm.box_url = "http://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  (1..$num_instances).each do |i|

    config.vm.define vm_name = $instance_name % i do |config|

      config.vm.hostname = vm_name
      config.vm.network :private_network, ip: $instance_ip % i
      if i == 1
	config.vm.network "forwarded_port", guest: 7776, host: 7776
	config.vm.network "forwarded_port", guest: 9998, host: 9998
      else
	config.vm.network "forwarded_port", guest: 7777, host: 7777
	config.vm.network "forwarded_port", guest: 9999, host: 9999
      end

      config.vm.provider :virtualbox do |virtualbox|
        virtualbox.gui = $virtualbox_gui
        virtualbox.memory = $virtualbox_memory
        virtualbox.cpus = $virtualbox_cpus
      end

      config.vm.provision :file, :source => "coreos-userdata", :destination => "/tmp/vagrantfile-user-data"
      config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    end
  end
end
