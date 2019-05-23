docker build -t api-herois .
docker run -p 3000:3000 --link mongodb:mongodb -e MONGO_URL=mongodb api-herois
docker run -d --name mongodb mongo:3.5
docker logs -f api-herois

docker stop $(docker ps -a -q)

### Docker register
docker login
docker build -t renanaragao/api-herois:v1 .
docker push renanaragao/api-herois:v1

### AZ CLI
az account set --subscription "<nome>"
az group create --name k8s-curso --location eastus

### AZ ACR - Registrar container
az acr create --resource-group k8s-curso --name refimagens --sku Basic
"refimagens.azurecr.io"
az acr login --name refimagens
az acr list --resource-group k8s-curso --output table
docker tag renanaragao/api-herois:v1 refimagens.azurecr.io/api-herois:v1
docker push refimagens.azurecr.io/api-herois:v1
az acr credential show -n refimagens --query passwords[0].value

### Contianer Services
az container create --resource-group k8s-curso `
   --name mongodb --image mongo:3.5 `
   --cpu 1 --memory 1 `
   --port 27017 `
   --ip-address public
az container logs --resource-group k8s-curso --name mongodb
az container show --resource-group k8s-curso --name mongodb --query ipAddress.ip
az container create --resource-group k8s-curso `
   --name api-herois --image refimagens.azurecr.io/api-herois:v1 `
   --cpu 1 --memory 1 `
   --port 3000 `
   --environment-variables MONGO_URL=52.191.216.12 `
   --registry-username refimagens `
   --registry-password 42/HMspgt/kv2jrqEUcbTQr2h86OJ4+Z `
   --ip-address public

### AKS
az aks create -g k8s-curso `
    --name refcluster `
    --dns-name-prefix refcluster `
    --generate-ssh-keys `
    --node-count 2
az aks install-cli
az aks get-credentials --resource-group k8s-curso --name refcluster
kubectl get nodes
kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks browse --resource-group k8s-curso --name refcluster