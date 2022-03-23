provider "ibm" {
  region = var.region
}

data "ibm_is_zones" "this" {
  region = var.region
}

data "ibm_resource_group" "this" {
  name = var.ibm_resource_group
}

resource "random_id" "this" {
  byte_length = 2
}
resource "tls_private_key" "insecure" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  ssh_key_public  = sensitive(tls_private_key.insecure.public_key_openssh)
  ssh_key_private = sensitive(tls_private_key.insecure.private_key_pem)
}

resource "ibm_is_ssh_key" "this" {
  name       = "${var.prefix}-${var.region}-${random_id.this.hex}-ssh-key"
  public_key = local.ssh_key_public
}

resource "ibm_is_vpc" "this" {
  name           = "${var.prefix}-${var.region}-${random_id.this.hex}-vpc"
  resource_group = data.ibm_resource_group.this.id
}

resource "ibm_is_subnet" "this" {
  name                     = "${var.prefix}-${var.region}-${random_id.this.hex}-subnet"
  zone                     = data.ibm_is_zones.this.zones[0]
  vpc                      = ibm_is_vpc.this.id
  total_ipv4_address_count = var.total_ipv4_address_count
}

#########1#########2#########3#########4#########5#########6#########7#########8
# SG Rules
#########1#########2#########3#########4#########5#########6#########7#########8

resource "ibm_is_security_group_rule" "icmp" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  icmp {
    code = 0
    type = 8
  }
}

resource "ibm_is_security_group_rule" "http" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "ssh" {
  group     = ibm_is_vpc.this.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

data "ibm_is_image" "ubuntu-20-04-3" {
  name = "ibm-ubuntu-20-04-3-minimal-amd64-1"
}

locals {
  version         = var.image_version
  last_image_name = "${var.image_name}-${local.version}-${random_id.this.hex}"
}

resource "null_resource" "run_packer" {
  triggers = {
    when_version_changed = join("-", tolist([var.image_name, var.image_version, random_id.this.hex]))
  }

  provisioner "local-exec" {
    command = <<EOH
cd ../packer
ansible-galaxy install geerlingguy.docker
ansible-galaxy install vantaworks.goss
packer version
packer init ./ubuntu_focal.pkr.hcl
timeout 60m packer build \
-var region=${var.region} \
-var subnet_id=${ibm_is_subnet.this.id} \
-var security_group_id=${ibm_is_vpc.this.default_security_group} \
-var resource_group_id=${data.ibm_resource_group.this.id} \
-var vsi_base_image_name=${data.ibm_is_image.ubuntu-20-04-3.name} \
-var vsi_profile=${var.profile} \
-var vsi_user_data_file=./shell/user_data.sh \
-var ansible_file=./ansible/playbook.yml \
-var image_name=${local.last_image_name} \
-force \
-color=false \
./ubuntu_focal.pkr.hcl
EOH
  }
}

data "ibm_is_image" "ubuntu-20-04-3-docker" {
  depends_on = [
    null_resource.run_packer
  ]
  name = local.last_image_name
}

resource "ibm_is_instance" "one_from_the_image" {
  depends_on = [ibm_is_security_group_rule.ssh]

  name    = "${var.prefix}-${var.region}-${random_id.this.hex}-in-from-the-image"
  vpc     = ibm_is_vpc.this.id
  zone    = data.ibm_is_zones.this.zones[0]
  keys    = [ibm_is_ssh_key.this.id]
  image   = data.ibm_is_image.ubuntu-20-04-3-docker.id
  profile = var.profile

  primary_network_interface {
    subnet = ibm_is_subnet.this.id
  }
}

resource "ibm_is_floating_ip" "one_from_the_image" {
  name   = "${var.prefix}-${var.region}-${random_id.this.hex}-ip-from-the-image"
  target = ibm_is_instance.one_from_the_image.primary_network_interface[0].id
}

resource "null_resource" "ssh_one_from_the_image" {
  triggers = {
    fip_instance_id = ibm_is_instance.one_from_the_image.id
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = ibm_is_floating_ip.one_from_the_image.address
    private_key = local.ssh_key_private
    timeout     = "10m"
  }
  provisioner "remote-exec" {
    inline = [
      "echo $(uname -a)",
      "apt list --installed | grep unattended",
      "whereis docker"
    ]
  }
}
