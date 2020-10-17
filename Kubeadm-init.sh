ssh YOUR_ID@MASTER_IP_ADDRESS

sudo kubeadm init 

 mkdir -p $HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml 

#SCP this to all your worker nodes
scp -r $HOME/.kube gary@192.168.0.21:/home/YOUR_HOME_DIRECTORY

#Do the following on all your worker node:
ssh YOUR_ID@WORKER_NODE__IP_ADDRESS
    
sudo -i 
    #Copy the join command, token and cert from "kubeadm init" operation and run it below
    kubeadm join ----
exit
