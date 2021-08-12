BOX_IMAGE = "ubuntu/bionic64"

WORKER_COUNT = 2

MASTER_MEMORY = 1024
WORKER_MEMORY = 1024

POD_CIDR = "172.18.0.0/16"
KVMSG = "Matt's K8s lab"

COMMON_SCRIPT_URL = "https://raw.githubusercontent.com/mpryor/k8s-setup/master/common.sh"
MASTER_SCRIPT_URL = "https://raw.githubusercontent.com/mpryor/k8s-setup/master/master.sh"
WORKER_SCRIPT_URL = "https://raw.githubusercontent.com/mpryor/k8s-setup/master/worker.sh"


class KvLab

  def initialize
      p "********** #{KVMSG} **********"
  end

  def createMaster(config)
    config.vm.define "kube-master" do |master|
      master.vm.box = BOX_IMAGE
      master.vm.hostname = "kube-master"
      master.vm.network :public_network

      $script = ""

      master.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", 2]
        vb.memory = MASTER_MEMORY
      end

      if !BOX_IMAGE.include? "kuberverse"
        master.vm.provider "vmware_desktop" do |v|
          v.vmx["memsize"] = MASTER_MEMORY
          v.vmx["numvcpus"] = "2"
        end
      end

      $script = $script + <<-SCRIPT

        mkdir -p /home/vagrant/.kv

        wget -q #{COMMON_SCRIPT_URL} -O /home/vagrant/.kv/common.sh
        chmod +x /home/vagrant/.kv/common.sh
        /home/vagrant/.kv/common.sh

        wget -q #{MASTER_SCRIPT_URL} -O /home/vagrant/.kv/master.sh
        chmod +x /home/vagrant/.kv/master.sh
        IP=$(ifconfig enp0s8 | grep "inet " | awk '{print $2}')
        /home/vagrant/.kv/master.sh #{POD_CIDR} $IP
      SCRIPT
      master.vm.provision "shell", inline: $script
    end
  end

  def createWorker(config)
    (0..WORKER_COUNT-1).each do |i|
      config.vm.define "kube-worker-#{i}" do |worker|
        worker.vm.box = BOX_IMAGE
        worker.vm.hostname = "kube-worker-#{i}"
        worker.vm.network :public_network
        worker.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--cpus", 2, "--natdnshostresolver1", "on"]
          vb.memory = WORKER_MEMORY
        end

        if !BOX_IMAGE.include? "kuberverse"
          worker.vm.provider "vmware_desktop" do |v|
            v.vmx["memsize"] = WORKER_MEMORY
            v.vmx["numvcpus"] = "2"
          end
        end

        $script = <<-SCRIPT
          mkdir -p /home/vagrant/.kv

          wget -q #{COMMON_SCRIPT_URL} -O /home/vagrant/.kv/common.sh
          chmod +x /home/vagrant/.kv/common.sh
          /home/vagrant/.kv/common.sh

          wget -q #{WORKER_SCRIPT_URL} -O /home/vagrant/.kv/worker.sh
          chmod +x /home/vagrant/.kv/worker.sh
          IP=$(ifconfig enp0s8 | grep "inet " | awk '{print $2}')
          /home/vagrant/.kv/worker.sh $IP 
        SCRIPT
        worker.vm.provision "shell", inline: $script
      end
    end
  end
end

Vagrant.configure("2") do |config|
  kvlab = KvLab.new()

  kvlab.createMaster(config)
  kvlab.createWorker(config)

  config.vm.provision "shell",
   run: "always",
   inline: "swapoff -a"
end
