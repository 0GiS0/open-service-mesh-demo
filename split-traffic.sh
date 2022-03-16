# Clone repository
git clone https://github.com/0GiS0/open-service-mesh-demo

# Change branch
git checkout traffic-split

YOUR_DOCKER_HUB_USER="<your docker hub user>"

# Generate docker images
docker build -t $YOUR_DOCKER_HUB_USER/bookstore bookstore/.
docker build -t $YOUR_DOCKER_HUB_USER/moviestore moviestore/.
docker build -t $YOUR_DOCKER_HUB_USER/bookthief bookthief/.
docker build -t $YOUR_DOCKER_HUB_USER/bookbuyer bookbuyer/.


# Publish Movistore image in Docker Hub
docker push $YOUR_DOCKER_HUB_USER/bookstore
docker push $YOUR_DOCKER_HUB_USER/moviestore
docker push $YOUR_DOCKER_HUB_USER/bookthief
docker push $YOUR_DOCKER_HUB_USER/bookbuyer

# Create namespaces
k create ns stores 
k create ns bookbuyer 
k create ns bookthief

# Add namespaces to osm
export PATH=$PATH:./darwin-amd64/
osm namespace add stores bookbuyer bookthief

# Deploy Movistore in AKS/K8s cluster
kubectl apply -f manifests/

# Install nginx
kubectl create ns ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install osm-nginx-ingess ingress-nginx/ingress-nginx --namespace ingress-nginx

# Get nginx ingress controller public IP
kubectl get svc -n ingress-nginx osm-nginx-ingess-ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Add ingress to access from outside
##### YOU HAVE TO CHANGE THE IP ADDRESS ######
kubectl apply -f ingress/

# Check access
http://bookbuyer.<PUBLIC_IP_INGRESS>.nip.io
http://bookthief.<PUBLIC_IP_INGRESS>.nip.io
http://bookstore.<PUBLIC_IP_INGRESS>.nip.io
http://moviestore.<PUBLIC_IP_INGRESS>.nip.io

# Check permissive mode
kubectl get meshconfig osm-mesh-config -n osm-system -o jsonpath='{.spec.traffic.enablePermissiveTrafficPolicyMode}{"\n"}'

# Change to permissive mode to false
kubectl patch meshconfig osm-mesh-config -n osm-system -p '{"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":false}}}'  --type=merge

# Update traffic access
kubectl apply -f traffic-access/traffic-policies.yaml

# Apply Traffic split
kubectl apply -f traffic-split/split-between-bookstore-and-moviestore.yaml