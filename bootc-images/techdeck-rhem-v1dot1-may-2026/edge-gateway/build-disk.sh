mkdir -p /home/ken/bootc-builder/{tmp,output,run-osbuild}

sudo podman run --rm -it \
  --privileged \
  --pull=newer \
  --security-opt label=type:unconfined_t \
  -e TMPDIR=/var/tmp \
  -v ./config.toml:/config.toml:ro \
  -v /home/ken/bootc-builder/output:/output \
  -v /home/ken/bootc-builder/tmp:/var/tmp \
  -v /home/ken/bootc-builder/run-osbuild:/run/osbuild \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  quay.io/centos-bootc/bootc-image-builder:latest \
  build \
  --type anaconda-iso \
  --output /output \
  quay.io/kenosborn/gateway-summit2k6-bootc:v1
