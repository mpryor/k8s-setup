UBUNTU_CODENAME=$(lsb_release -cs)

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable"

  ### Refresh apt cache
apt-get update

apt-get install -y nfs-kernel-server nfs-common avahi-daemon libnss-mdns traceroute htop httpie bash-completion ruby docker-ce=5:19.03.13~3-0~ubuntu-$UBUNTU_CODENAME kubeadm kubelet kubectl


cat /vagrant/hosts.out >> /etc/hosts

# Setup Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker
systemctl daemon-reload
systemctl restart docker

kubeadm config images pull
