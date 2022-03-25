[![pre-commit](https://github.com/ibm-xaas/iaas-custom-image-ubuntu-focal-consul/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/ibm-xaas/iaas-custom-image-ubuntu-focal-consul/actions/workflows/pre-commit.yaml)
# iaas-custom-image-ubuntu-focal-consul
ubuntu 20.04 custom image for ibm cloud
- removed unattended upgrades
- installed docker & docker-compose
- goss
- consul (based on the instruction from [consul getting-started](https://learn.hashicorp.com/tutorials/consul/get-started-install?in=consul/getting-started) )
- envoy proxy (based on the instruction from [envoyproxy](https://www.envoyproxy.io/docs/envoy/latest/start/install))

## how to test (create a custom image in us-south region)
```
export IBMCLOUD_API_KEY=<YOUR IBMCLOUD API KEY>
docker-compose run iaas-custom-image-ubuntu-focal-consul  ./build_image.sh
```

Due to the limitation of the current [packer-plugin-ibmcloud](https://github.com/IBM/packer-plugin-ibmcloud), it's a little difficult to create custom images with multiple regions, that's doable just a little more consideration to be working on. It's good enough for now.

# History
03/22/22 transferred from the personal org to ibm-xaas

After creating the image, I've followed the tutorial [Consul on VMs](https://learn.hashicorp.com/tutorials/consul/get-started?in=consul/getting-started)
![image](https://user-images.githubusercontent.com/67604276/160124784-65155720-14a2-4714-8478-99a3404aab00.png)
