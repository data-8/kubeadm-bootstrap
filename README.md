## Kubeadm Bootstrapper

This repository contains a bunch of helper scripts to set up Kubernetes clusters
using kubeadm. It is meant for use on bare-metal clusters, as well as VMs
that are being treated like bare-metal clusters for various reasons. 

This is just a wrapper around `kubeadm` to provide sane defaults.

## Pre-requisites

### Operating System

This has been tested on Ubuntu 16.04 only. We would welcome patches to support
CentOS / RHEL 7. The Overlay filesystem must be enabled in your kernel - it is
by default, so if you didn't fiddle with it you are good!

### Networking

All nodes in the cluster must have unrestricted outbound internet access. This
is for pulling in docker images & debian packages.

At least one node in the cluster must have a public IP if you want to expose
network services to the world (via Ingress).

Ideally traffic between the various nodes is unrestricted by any firewall rules.
If you need list of specific ports to open, please open an issue and we'll
figure it out.

### ssh

You must have ssh access to all the nodes. You also need root :)

## Setting up a cluster

### Setting up a Master Node

1. Clone this git repository on to your master node
   `git clone https://github.com/data-8/kubeadm-bootstrap`
   
2. Install the pre-requisites for starting the master. Run this as root!
   ```bash
   ./install-kubeadm.bash
   ```
   
   This installs kubeadm, a supported version of docker and sets up the
   appropriate storage driver options for docker.
   
3. Prepare your config files! There's a sample one in `data/config.bash.sample` that
   shows you how to make one. You should copy it to `data/config.bash` and fill
   in the values. The primary values we care about are:
   
   a. `KUBE_MASTER` - the IP of the kubernetes master node that the worker nodes
       can reach it at. 

   b. `KUBEADM_TOKEN` - the token used by worker nodes to join the kubernetes
       cluster. You can generate this by running `kubeadm token generate` and
       noting down that value.
       
       **WARNING**: Keep the `KUBEADM_TOKEN` very private - users with access to
       this can get root on your cluster easily. Treat it the same as you would
       a root ssh key or password!
   
4. Setup the master - run this as root too!
   ``` bash
   ./init-master.bash
   ```
   
   This will take a minute or two, but should set up and install the following:
   
   a. A Kubernetes Master with all the required components (etcd, apiserver,
      scheduler and controller-manager)

   b. Flannel with VXLAN backend for the Pod Network

   c. A very permissive cluster binding - mimics the way permissions worked up
      to Kubernetes 1.5. This will probably go away once more tools get proper
      RBAC support.

   d. Helm for installing software on to the cluster.

   e. An nginx ingress that is installed on all nodes - this is used to get
      network traffic into the cluster. This is installed via helm.

   d. kube-lego for automated Let's Encrypt certificates. This is also installed
      via helm.
   
   e. Symlinks `/etc/kubernetes/admin.conf` to `~/.kube/config` - this contains
      credentials and connection info for connecting to the master. If you want
      to allow other users to connect to the k8s master, give them access to
      this file too.

   The master node is also marked as schedulable - this might not be ideal if
   you are running a large cluster, but is useful otherwise. This also means
   that if you only wanted a single node Kubernetes cluster, you are already
   done!
   
5. Test that everything is up!

   a. Run `kubectl get node` - you should see one node (your master node) marked
      as `Ready`.

   b. Run `kubectl --namespace=kube-system get pod`. Everything should be in
      `Running` state. If it's still `Pending`, give it a couple minutes. If
       they are in `Error` or `CrashLoopBackoff` state, something is wrong.

   c. Do 'curl localhost' - it should output `404 Not Found`. This means network
      traffic into the cluster is working. If your master node also has an external
      IP that is accessible from the internet, try hitting that too - it should
      also return the same thing. If not, you might be having firewall issues -
      check to make sure traffic can reach the master node from outside!
   

Congratulations, now you have a single node kubernetes cluster that can also act
as a Kubernetes master for other nodes!

### Setting up a worker node

1. Clone this git repository on to your worker node
   `git clone https://github.com/data-8/kubeadm-bootstrap`
   
2. Install the pre-requisites for setting up a node. This is the same script
   used for setting up the master too. Again, run this as root.
   ```bash
   ./install-kubeadm.bash
   ```
   
   This installs kubeadm, a supported version of docker and sets up the
   appropriate storage driver options for docker.

3. Copy `data/config.bash` file you prepared for the master onto this checkout
   of the repository. Remember to not commit this file onto git - it contains
   the important `KUBEADM_TOKEN` that provides root-equivalent access to the
   kubernetes cluster.
   
4. Setup the node! Run this as root too.
   ```bash
   ./init-worker.bash
   ```
   
   This will take a few minutes too. It sets up the current node to be a
   Kubernetes worker node, and automatically tries to connect to the master (via
   the `KUBE_MASTER_IP` & `KUBEADM_TOKEN` variables from `data/config.bash`) and
   bootstrap itself. When this completes successfully, it means your node is up!
   
5. Test that everything is up!

   a. On the master, run `kubectl get node` - it should list your new node in
      `Ready` state.

   b. Run `kubectl --namespace=kube-system get pod -o wide`. This should show
      you a `kube-proxy`, a `flannel` and `nginx-controller` pod running on your
      new node in `Ready` state. If it is in `Pending` state, give it a few minutes
      to get to `Ready`. If it's in `Error` or `CrashLoopBackoff` you have a
      problem.

   c. Do `curl localhost` - it should output `404 Not Found`. This means network
      traffic into your cluster is working. If this worker node also has a public
      IP that is accessible from the internet, hit that too - you should get the
      same output. If not, you might be having firewall issues - check to make sure
      traffic can reach this worker node from outside!
      
Congratulations, you have a working multi-node Kubernetes cluster! You can
repeat these steps to add as many new nodes as you want :)
   
## Next step?

1. If you want to install JupyterHub on this cluster, follow the instructions in
   the [Zero to JupyterHub guide](https://z2jh.jupyter.org)
2. You can look for other software to install from the official kubernetes
   charts repository.
