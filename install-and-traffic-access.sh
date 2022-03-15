# Variables
RESOURCE_GROUP="open-service-mesh-demo"
LOCATION="westeurope"
AKS_NAME="aks-osm"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS
az aks create \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME \
--generate-ssh-keys

# Get credentials
az aks get-credentials \
--resource-group $RESOURCE_GROUP \
--name $AKS_NAME

# Download and install OSM command-line tool
curl -L https://github.com/openservicemesh/osm/releases/download/v1.0.0/osm-v1.0.0-darwin-amd64.tar.gz | tar -vxzf -

# Export osm to the PATH
export PATH=$PATH:./darwin-amd64/
osm version

# Install OMS on Kubernetes
export osm_namespace=osm-system # Replace osm-system with the namespace where OSM will be installed
export osm_mesh_name=osm # Replace osm with the desired OSM mesh name

osm install \
--mesh-name "$osm_mesh_name" \
--osm-namespace "$osm_namespace" \
--set=osm.enablePermissiveTrafficPolicy=true \
--set=osm.deployPrometheus=true \
--set=osm.deployGrafana=true \
--set=osm.deployJaeger=true

# Check OMS status
kubectl get pods -n "$osm_namespace"

#############################
# Deploy Sample application #
#############################

# Generate Docker images
docker build -t 0gis0/bookstore bookstore/.
docker build -t 0gis0/bookbuyer bookbuyer/.
docker build -t 0gis0/bookthief bookthief/.

docker images

# Try to execute the app in Docker
# Create a network for the containers
docker network create bookstore-net

# Create the containers
docker run -d --name bookstore -p 8080:3000 --network bookstore-net 0gis0/bookstore 
docker run -d --name bookbuyer -p 8081:4000 --network bookstore-net 0gis0/bookbuyer
docker run -d --name bookthief -p 8082:4001 --network bookstore-net 0gis0/bookthief

##################################
# Deploy this application in AKS #
##################################

# Publish images in Docker Hub
docker push 0gis0/bookstore
docker push 0gis0/bookbuyer
docker push 0gis0/bookthief

# Deploy manifests in AKS/K8s cluster
kubectl apply -f manifests/.

# Check if the pods are ready
kubectl get pods -n bookstore
kubectl get pods -n bookbuyer
kubectl get pods -n bookthief

# Check if the services are ready
kubectl get services -n bookstore
kubectl get services -n bookbuyer
kubectl get services -n bookthief

# Now we enable osm for their namespaces
osm namespace add bookstore bookbuyer bookthief

# Check what namespaces are monitored by osm
osm namespace list

# deployment restart
kubectl rollout restart deployment/bookthief -n bookthief
kubectl rollout restart deployment/bookbuyer -n bookbuyer
kubectl rollout restart deployment/bookstore -n bookstore

# Now you have two container instead of one per each pod
kubectl get pods -n bookstore
kubectl get pods -n bookbuyer
kubectl get pods -n bookthief

kubectl describe pod -n bookstore 

# We lost access from outside. We have to configure a Ingress Controller
# Configure nginx ingress controller
kubectl create ns ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install osm-nginx-ingess ingress-nginx/ingress-nginx --namespace ingress-nginx

# osm namespace add ingress-nginx

# Get nginx ingress controller public IP
kubectl get svc -n ingress-nginx osm-nginx-ingess-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Create a ingress rules and ingress backends
kubectl apply -f ingress/.

# Now you can access using this URLs
http://bookstore.<INGRESS_PUBLIC_IP>.nip.io/
http://bookbuyer.<INGRESS_PUBLIC_IP>.nip.io/
http://bookthief.<INGRESS_PUBLIC_IP>.nip.io/


# Check permissive mode
kubectl get meshconfig osm-mesh-config -n osm-system -o jsonpath='{.spec.traffic.enablePermissiveTrafficPolicyMode}{"\n"}'

# Change to permissive mode to false
kubectl patch meshconfig osm-mesh-config -n osm-system -p '{"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":false}}}'  --type=merge

# Now you need to create traffic policies
kubectl apply -f traffic-access/.
