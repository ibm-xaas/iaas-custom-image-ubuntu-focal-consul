[![pre-commit](https://github.com/syyang-in-cloud/iaas-custom-image-ubuntu-focal-consul/actions/workflows/pre-commit.yaml/badge.svg?branch=main)](https://github.com/syyang-in-cloud/iaas-custom-image-ubuntu-focal-consul/actions/workflows/pre-commit.yaml)
# iaas-custom-image-ubuntu-focal-consul
ubuntu 20.04 custom image for ibm cloud
- removed unattended upgrades
- installed docker & docker-compose
- goss
- consul

## how to test (create a custom image in us-south region)
```
export IBMCLOUD_API_KEY=<YOUR IBMCLOUD API KEY>
docker-compose run iaas-custom-image-ubuntu-focal-consul  ./build_image.sh
```

Due to the limitation of the current [packer-plugin-ibmcloud](https://github.com/IBM/packer-plugin-ibmcloud), it's a little difficult to create custom images with multiple regions, that's doable just a little more consideration to be working on. It's good enough for now.
