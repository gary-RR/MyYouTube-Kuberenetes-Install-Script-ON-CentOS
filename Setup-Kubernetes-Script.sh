#Run these on all your servers that will be part of the Kubernetes cluster

#Config firewall
sudo -i
  firewall-cmd --permanent --add-port=6443/tcp
  firewall-cmd --permanent --add-port=2379-2380/tcp
  firewall-cmd --permanent --add-port=10250/tcp
  firewall-cmd --permanent --add-port=10251/tcp
  firewall-cmd --permanent --add-port=10252/tcp
  firewall-cmd --permanent --add-port=10255/tcp 
  #Also opne dynaic ports 30000 to 32767 for "NodePort" access.
  firewall-cmd --permanent --add-port=30000-32767/tcp
  firewall-cmd --zone=trusted --permanent --add-source=192.168.0.0/24
  firewall-cmd --add-masquerade --permanent
  
  #Netfilter offers various functions and operations for packet filtering, network address translation, and port translation, which provide the functionality required for directing packets through a network 
  #modprobe - program to add and remove modules from the Linux Kernel
  modprobe br_netfilter
  systemctl restart firewalld
exit


#Add both servers to hosts file
sudo nano /etc/hosts
192.168.0.20    kube-master
192.168.0.21    kube-node1

# Docker packages are not available anymore on CentOS 8 or RHEL 8 package repositories, so run following dnf command to enable Docker CE package repository.
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

#Install Docker
sudo dnf install docker-ce --nobest -y --allowerasing

#Start and enable the Docker daemon
sudo systemctl enable --now docker

#Add your user to the docker group
sudo usermod -aG docker $USER

#logoof and log back in
exit
ssh YOUR_ID@NODE_YOU_WERE_WORKING_ON

#Veiry docker installed correctly
docker --version
docker run hello-world

#Now we can install Kubernetes on CentOS. First, we must create a new repository:
sudo nano /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg

#Install Kubernetes
sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

#Modify kubelet file
sudo nano /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS= --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice

#Start the Kubernetes service
sudo systemctl enable --now kubelet

#Now we’re going to have to su to the root user and then create a new file (to help configure iptables):
sudo -i
  nano /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-ip6tables = 1
  net.bridge.bridge-nf-call-iptables = 1

  #Load the new configuration
  sysctl --system
  
  #Disable swap
  sudo swapoff -a
  #Also premanently disable swap
  sudo nano /etc/fstab
      #/dev/mapper/cl-swap

  #Create a docker Daemon File  
  nano /etc/docker/daemon.json
  {
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "storage-opts": [
      "overlay2.override_kernel_check=true"
    ]
  }   

  mkdir -p /etc/systemd/system/docker.service.d
  systemctl daemon-reload
  systemctl restart docker
exit


# sudo firewall-cmd --permanent --add-port=63/tcp
  # sudo firewall-cmd --permanent --add-port=63/udp
  # sudo firewall-cmd --permanent --add-port=67/tcp
  # sudo firewall-cmd --permanent --add-port=67/udp
  # sudo firewall-cmd --permanent --add-port=68/tcp
  # sudo firewall-cmd --permanent --add-port=68/udp
  # firewall-cmd --permanent --add-port=8472/udp
  # firewall-cmd --add-masquerade --permanent