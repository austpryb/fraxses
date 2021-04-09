---
### Refer to 01-chainlink-operator/google/modules/k8s/avalanche.tf to see how the Kubernetes deployment references this build. 

Official node implementation of the [Avalanche](https://avax.network) network 

<strong>04-Avalanche</strong> project directory has been cloned from the [official](https://github.com/ava-labs/avalanchego) Avalanche node repository and adapted to run in Kubernetes

You can build, tag, and run this modified Docker image from your own registry like so...

```
# Build and tag the image from Dockerfile
docker build . -t <your-docker-registry>/avalanchego:001 

# Sign up for a free repo at https://www.docker.com/
docker login 

#push to your repo
docker push <your-docker-registry>/avalanchego:001
```

or keep the source Terraform configuration as is in which case Kubernetes deployments will pull from my modified build like so...

```
docker pull austpryb/avalanchego:001
```


