git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus
# Create the namespace and CRDs, and then wait for them to be available before creating the remaining resources
kubectl create -f manifests/setup
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
kubectl create -f manifests/

cd ..
rm -rf kube-prometheus
