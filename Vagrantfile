BOX_IMAGE = "kuberverse/ubuntu-16.04"

# Change these values if you wish to play with the
# cluster size. Do this before starting your cluster
# provisioning.
MASTER_COUNT = 1
WORKER_COUNT = 2

# Change these values if you wish to play with the
# VMs memory resources.
SCALER_MEMORY = 512
MASTER_MEMORY = 1024
WORKER_MEMORY = 1024

# Change these values if you wish to play with the
# networking settings of your cluster
KV_LAB_NETWORK = "10.8.8.0"

# This value changes the intra-pod network
POD_CIDR = "172.18.0.0/16"


KVMSG = "Kuberverse Kubernetes Cluster Lab"

COMMON_SCRIPT_URL = "https://raw.githubusercontent.com/arturscheiner/kuberverse/master/labs/kv-k8s-cluster-ha/common.sh"
SCALER_SCRIPT_URL = "https://raw.githubusercontent.com/arturscheiner/kuberverse/master/labs/kv-k8s-cluster-ha/scaler.sh"
MASTER_SCRIPT_URL = "https://raw.githubusercontent.com/arturscheiner/kuberverse/master/labs/kv-k8s-cluster-ha/master.sh"
WORKER_SCRIPT_URL = "https://raw.githubusercontent.com/arturscheiner/kuberverse/master/labs/kv-k8s-cluster-ha/worker.sh"


class KvLab

  def initialize
      p "********** #{KVMSG} **********"
  end

  def defineIp(type,i,kvln)
      case type
      when "master"
        return kvln.split('.')[0..-2].join('.') + ".#{i + 10}"
      when "worker"
        return kvln.split('.')[0..-2].join('.') + ".#{i + 20}"
      when "scaler"
        return kvln.split('.')[0..-2].join('.') + ".#{i + 50}"
      end
  end

  def createScaler(config)

      if MASTER_COUNT == 1
        p "This is a Single Master Cluster with:"
        p "---- #{MASTER_COUNT} Master Node"
        p "---- #{WORKER_COUNT} Worker(s) Node(s)"
        return
      end

      p "This is a HA Cluster with:"
      p "---- 1 Scaler Node"
      p "---- #{MASTER_COUNT} Masters Nodes"
      p "---- #{WORKER_COUNT} Worker(s) Node(s)"

      i = 0
      scalerIp = self.defineIp("scaler",i,KV_LAB_NETWORK)

      p "The Scaler #{i} Ip is #{scalerIp}"

      masterIps = Array[]

      (0..MASTER_COUNT-1).each do |m|
        masterIps.push(self.defineIp("master",m,KV_LAB_NETWORK))
      end

      # p masterIps.length
      # masterIps.each {|s| p s}

      config.vm.define "kv-scaler-#{i}" do |scaler|
        scaler.vm.box = BOX_IMAGE
        scaler.vm.hostname = "kv-scaler-#{i}"
        scaler.vm.network :private_network, ip: scalerIp
        scaler.vm.network "forwarded_port", guest: 6443, host: 6443

        scaler.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--cpus", 2]
          vb.memory = SCALER_MEMORY
        end

        if !BOX_IMAGE.include? "kuberverse"
          scaler.vm.provider "vmware_desktop" do |v|
            v.vmx["memsize"] = SCALER_MEMORY
            v.vmx["numvcpus"] = "2"
          end
        end

        $script = <<-SCRIPT
          echo "# Added by Kuberverse" > /vagrant/hosts.out
          echo "#{scalerIp} kv-scaler.lab.local kv-scaler.local kv-master" >> /vagrant/hosts.out

          mkdir -p /home/vagrant/.kv
          wget -q #{SCALER_SCRIPT_URL} -O /home/vagrant/.kv/scaler.sh
          chmod +x /home/vagrant/.kv/scaler.sh
          /home/vagrant/.kv/scaler.sh "#{KVMSG}" #{scalerIp} "#{masterIps}"
        SCRIPT
        scaler.vm.provision "shell", inline: $script
      end
  end

  def createMaster(config)

    (0..MASTER_COUNT-1).each do |i|
      masterIp = self.defineIp("master",i,KV_LAB_NETWORK)

      p "The Master #{i} Ip is #{masterIp}"
      config.vm.define "kv-master-#{i}" do |master|
        master.vm.box = BOX_IMAGE
        master.vm.hostname = "kv-master-#{i}"
        master.vm.network :public_network

        $script = ""

        if MASTER_COUNT == 1
          #master.vm.network "forwarded_port", guest: 6443, host: 6443
          $script = <<-SCRIPT
            echo "# Added by Kuberverse" > /vagrant/hosts.out
            echo "#{masterIp} kv-master.lab.local kv-master.local kv-master" >> /vagrant/hosts.out
          SCRIPT
        end

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
          /home/vagrant/.kv/common.sh "#{KVMSG}" #{BOX_IMAGE}

          wget -q #{MASTER_SCRIPT_URL} -O /home/vagrant/.kv/master.sh
          chmod +x /home/vagrant/.kv/master.sh
          IP=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
          /home/vagrant/.kv/master.sh "#{KVMSG}" #{i} #{POD_CIDR} $IP #{MASTER_COUNT == 1 ? "single" : "multi"}
        SCRIPT
        master.vm.provision "shell", inline: $script
      end
    end
  end

  def createWorker(config)
    (0..WORKER_COUNT-1).each do |i|
      workerIp = self.defineIp("worker",i,KV_LAB_NETWORK)

      p "The Worker #{i} Ip is #{workerIp}"
      config.vm.define "kv-worker-#{i}" do |worker|
        worker.vm.box = BOX_IMAGE
        worker.vm.hostname = "kv-worker-#{i}"
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
          /home/vagrant/.kv/common.sh "#{KVMSG}" #{BOX_IMAGE}

          wget -q #{WORKER_SCRIPT_URL} -O /home/vagrant/.kv/worker.sh
          chmod +x /home/vagrant/.kv/worker.sh
          IP=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
          /home/vagrant/.kv/worker.sh "#{KVMSG}" #{i} $IP #{MASTER_COUNT == 1 ? "single" : "multi"}
        SCRIPT
        worker.vm.provision "shell", inline: $script
      end
    end
  end
end

Vagrant.configure("2") do |config|

  kvlab = KvLab.new()

  kvlab.createScaler(config)
  kvlab.createMaster(config)
  kvlab.createWorker(config)


  config.vm.provision "shell",
   run: "always",
   inline: "swapoff -a"

end
