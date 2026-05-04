
# Upstream (old); doesn't work for downstream
```
sudo podman build -t quay.io/kenosborn/gateway-summit2k6-bootc:v1 .
```

# Downstream (works)
```
sudo podman build --no-cache \
  -t quay.io/kenosborn/gateway-summit2k6-bootc:v1 .
```

# Push to quay repo
```
sudo podman push quay.io/kenosborn/gateway-summit2k6-bootc:v1
```
