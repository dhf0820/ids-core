SHA=$(git rev-parse HEAD)

docker build -t dhf0820/delivery-manager:latest -f ./delivery-manager/Dockerfile ./delivery-manager


docker push dhf0820/delivery-manager:latest


docker tag dhf0820/delivery-manager:latest  dhf0820/delivery-manager:$SHA


docker push dhf0820/delivery-manager:$SHA


kubectl apply -f k8s-local
kubectl set image deployments/delivery-manager delivery-manager=dhf0820/delivery-manager:$SHA
