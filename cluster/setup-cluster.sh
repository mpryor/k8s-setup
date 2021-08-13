#!/bin/bash
GREEN='\033[0;32m'
RESET='\033[0m' # No Color

function header() {
	printf "\n\n==============================="
	printf "\n${GREEN}${1}${RESET}"
	printf "\n===============================\n"
}

header "Installing metallb..."
cd metallb
./install.sh
cd ..

header "Installing metrics server"
kubectl apply -f metrics-server/components.yml

header "Setting up a demo pod and demo service"
kubectl apply -f getting-started-k8s/Pods/pod.yml
kubectl apply -f getting-started-k8s/Services/svc-lb.yml

header "Installing k8s dashboard"
cd k8s-dashboard
./install.sh
cd ..

header "Installing prometheus/alertmanager/gafana"
cd kube-prometheus
./install.sh
cd ..
