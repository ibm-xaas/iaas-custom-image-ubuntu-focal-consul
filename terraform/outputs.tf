#output "vpc" {
#  value = ibm_is_vpc.this
#}

output "baked_image" {
  value = data.ibm_is_image.ubuntu-20-04-3-docker
}

output "list_of_images" {
  value = data.ibm_is_images.list_ubuntu_focal_consul.images
}
