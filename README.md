This module support run nginx and php-fpm same container

# How to build docker image
```bash

docker buildx build --push --platform linux/amd64,linux/arm64 . --tag dylanops/kube-php:8.3

```

# Magento

composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition:2.4.7 m247cc

minikube service hello-minikube --url
