POD_CIDR=$1
MASTER_IP=$2

wget -q https://docs.projectcalico.org/manifests/calico.yaml -O /tmp/calico-default.yaml
sed "s+192.168.0.0/16+$POD_CIDR+g" /tmp/calico-default.yaml > /tmp/calico-defined.yaml

kubeadm init --pod-network-cidr $POD_CIDR --apiserver-advertise-address $MASTER_IP --apiserver-cert-extra-sans kv-master.lab.local | tee /vagrant/kubeadm-init.out

k=$(grep -n "kubeadm join $MASTER_IP" /vagrant/kubeadm-init.out | cut -f1 -d:)
x=$(echo $k | awk '{print $1}')
awk -v ln=$x 'NR>=ln && NR<=ln+1' /vagrant/kubeadm-init.out | tee /vagrant/workers-join.out

mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

mkdir -p /vagrant/.kube
cp -i /etc/kubernetes/admin.conf /vagrant/.kube/config

kubectl apply -f /tmp/calico-defined.yaml

echo KUBELET_EXTRA_ARGS=--node-ip=$MASTER_IP  > /etc/default/kubelet
systemctl restart networking
systemctl restart kubelet

git clone https://github.com/mpryor/k8s-setup
cd k8s-setup
cd cluster
chmod +x cluster-setup.sh
./cluster-setup.sh
