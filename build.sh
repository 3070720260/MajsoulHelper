HTTP_PROXY=http://172.17.0.1:7890
HTTPS_PROXY=http://172.17.0.1:7890

# Build the frontend
docker build -t arthals/majsoul-helper-frontend \
 --build-arg HTTP_PROXY=$HTTP_PROXY \
 --build-arg HTTPS_PROXY=$HTTPS_PROXY \
 -f docker/Dockerfile.frontend .

# Build the backend
docker build -t arthals/majsoul-helper \
    --build-arg HTTP_PROXY=$HTTP_PROXY \
    --build-arg HTTPS_PROXY=$HTTPS_PROXY \
    -f docker/Dockerfile .