SHA=$(git rev-parse HEAD)

docker build -t dhf0820/delivery-manager:latest -f ./delivery-manager/Dockerfile .
#docker build -t dhf0820/ids-extractor:latest -f ./ids-extractor/Dockerfile .
#docker build -t dhf0820/ids-image-manager:latest -f ./ids-image-manager/Dockerfile .

docker push dhf0820/delivery-manager:latest
#docker push dhf0820/ids-extractor:latest
#docker push dhf0820/ids-image-manager:latest

docker tag dhf0820/delivery-manager:latest  dhf0820/delivery-manager:$SHA
#docker tag dhf0820/ids-extractor:latest  dhf0820/ids-extractor:$SHA
#docker tag dhf0820/ids-image-manager:latest  dhf0820/ids-image-manager:$SHA

docker push dhf0820/delivery-manager:$SHA
#docker push dhf0820/ids-extractor:$SHA
#docker push dhf0820/ids-image-manager:$SHA

kubectl apply -f k8s-local/delivery-manager-deployment.yaml
#kubectl set deploymentsl/delivery-manager image-manager=dhf0820/image-manager:$SHA

#kubectl set image deployments/demo-extractor demo-extractor=dhf0820/ids-extractor:$SHA