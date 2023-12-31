# Overview
VVDN-Intelligent Cloud Engine abbreviated as ICE is a secure and scalable cloud platform that enables IoT, Video, Automotive, AgriTech, HealthTech, and IIoT enterprises to quickly onboard devices and make them cloud-connected.


To learn more about VVDN-Intelligent Cloud Engine, see [this](https://cloud.vvdntech.com/intelligent-cloud-engine).


## Architecture
<img width="1378" alt="Screenshot 2023-10-19 at 11 27 11 AM copy" src="https://github.com/VVDN-Technologies/vvdn-ice/assets/124333816/a7432c03-b874-42cd-a259-18a441d926c4">

# Installation
## Quick Install with Google Cloud Marketplace

Create a new Google Cloud Platform project (recommended) or choose an existing one.

Get up and running with a few clicks! Install this VVDN ICE app to a Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the [on-screen instructions]

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to complete the following steps.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/VVDN-Technologies/vvdn-ice&cloudshell_open_in_editor=README.md)
### Prerequisites

#### Set up command-line tools

Make sure you have these tools installed.

- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [docker](https://docs.docker.com/install/)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

## Create a Google Kubernetes Engine cluster

If you have an existing GKE cluster you can use that otherwise you can create a new cluster from the command line.

Note: The Cluster need to be a minimum 7 Node Cluster, machine type to be e2-standard-4, image type to be Container-Optimized OS with containerd for optimum performance of the application.

```shell
export CLUSTER=YOUR_CLUSTER_NAME
export PROJECT=YOUR_PROJECT_ID
export REGION=YOUR_REGION
export ZONE=YOUR_ZONE

gcloud container clusters create $CLUSTER --region=$REGION --project $PROJECT --machine-type=e2-standard-4 --num-nodes=2
```
Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials $CLUSTER --region=$REGION --project $PROJECT
```

For zonal clusters, use --zone=ZONE instead of --region=REGION.

#### Clone this repo and the associated tools repo.

```shell
git clone https://github.com/VVDN-Technologies/vvdn-ice.git
cd vvdn-ice
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.
The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

#### Configure the app with environment variables

Choose the instance name and namespace for the app:

```shell
export APP_INSTANCE_NAME=vvdn-ice  #Sample name for the application
export NAMESPACE=default #Namespace where you want to deploy the application
```

#### Install the helm chart

```shell
helm install "$APP_INSTANCE_NAME" chart/vvdn-ice \
  --create-namespace --namespace "$NAMESPACE"
```

# Using the app

Retrieve IP address of the Ingress which is of loadbalancer type using this command

```shell
kubectl get ingress tb-http-loadbalancer-new -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```