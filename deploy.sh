#!/bin/bash

IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "ERROR: Docker image is required"
    echo "Usage: ./deploy.sh orderhub:<tag>"
    exit 1
fi

echo "================================="
echo "Deploying OrderHub"
echo "Image: $IMAGE"
echo "================================="

echo "Pulling image..."
docker pull "$IMAGE"

echo "Stopping old container..."

docker stop orderhub 2>/dev/null || true

echo "Removing old container..."

docker rm orderhub 2>/dev/null || true

echo "Starting new container..."

docker run -d \
    --name orderhub \
    -p 8080:8080 \
    "$IMAGE"

echo "Waiting for application health..."

for i in {1..12}
do
    if curl -f http://localhost:8080/health
    then
        echo ""
        echo "================================="
        echo "Deployment successful"
        echo "Image: $IMAGE"
        echo "================================="
        exit 0
    fi

    echo "Waiting..."
    sleep 5
done

echo "Health check failed."

echo "Rolling back / deployment failed."

docker logs orderhub

exit 1