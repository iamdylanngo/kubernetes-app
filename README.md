This module support run nginx and php-fpm same container

# How to build docker image
```bash

docker buildx build --push --platform linux/amd64,linux/arm64/v8 . --tag dylanops/kube-php:8.3

```