WORKER_IP=$1

$(cat /vagrant/kubeadm-init.out | grep -A 2 "kubeadm join" | sed -e 's/^[ \t]*//' | tr '\n' ' ' | sed -e 's/ \\ / /g')

echo KUBELET_EXTRA_ARGS=--node-ip=$WORKER_IP > /etc/default/kubelet

systemctl restart kubelet
