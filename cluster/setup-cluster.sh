cd metallb
./install.sh
cd ..

kubectl apply -f metrics-server/components.yml
kubectl apply -f getting-started-k8s/Pods/pod.yml
kubectl apply -f getting-started-k8s/Services/svc-lb.yml
