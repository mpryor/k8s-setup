Requirements

Virtualbox
Vagrant

Installation (via powershell) on Windows:

```
mkdir kubernetes
cd kubernetes
Invoke-WebRequest https://raw.githubusercontent.com/mpryor/k8s-setup/master/Vagrantfile -OutFile Vagrantfile
vagrant up
```
