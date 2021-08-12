# K8s-setup

## Description

This repo contains my current Kubernetes lab environment. I do not recommend using the architecture contained in this repo for production, it's purely for learning! Have fun!

## Requirements

Virtualbox
Vagrant

## Installation (via powershell) on Windows:

```
mkdir kubernetes
cd kubernetes
Invoke-WebRequest https://raw.githubusercontent.com/mpryor/k8s-setup/master/Vagrantfile -OutFile Vagrantfile
vagrant up
```

At this point you should have a cluster up and running.

Get into the control plane node by running `vagrant ssh kube-master`

Validate the environment is health by running a few kubectl commands:

```
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

If everything is looking good at this point, you're good to go.

## Grabbing the kubectl config 

An easy trick to grab the kubectl configuration from the control plane node is this:

1. Get on the control plane node `vagrant ssh kube-master`
2. Make sure you know the control plane node's IP: `ifconfig` . Most likely, you can just run this `ifconfig | grep 192.168 | awk '{print $2}'`
3. Open a socket to send the file over `cat ~/.kube/config | nc -l 1234`
4. NOTE: this will overwrite any pre-existing k8s config you have... From the machine you'd like to be able to run kubectl on, run this: `nc -v $CONTROL_PLANE_IP 1234 > ~/.kube/config` 

