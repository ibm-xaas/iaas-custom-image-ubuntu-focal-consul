
packer {
  required_plugins {
    ibmcloud = {
      version = ">=v2.2.0"
      source  = "github.com/IBM/ibmcloud"
    }
  }
}

variable "ibm_api_key" {
  type    = string
  default = "${env("IBMCLOUD_API_KEY")}"
}
variable "region" {
	type = string
}

variable "subnet_id" {
	type = string
}

#variable "security_group_id" {
#	type = string
#}

variable "resource_group_id" {
	type = string
}

variable "vsi_base_image_name" {
	type = string
}

variable "vsi_user_data_file" {
	type = string
}

variable "vsi_profile" {
	type = string
}

variable "ansible_file" {
	type = string
}

variable "image_name" {
	type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "ibmcloud-vpc" "ubuntu-focal" {
  api_key = "${var.ibm_api_key}"
  region  = var.region

  subnet_id         = var.subnet_id
  resource_group_id = var.resource_group_id
  #security_group_id = var.security_group_id

  vsi_base_image_name = var.vsi_base_image_name
  vsi_profile         = var.vsi_profile
  vsi_interface       = "public"
  vsi_user_data_file  = var.vsi_user_data_file

  image_name = var.image_name

  communicator = "ssh"
  ssh_username = "root"
  ssh_port     = 22
  ssh_timeout  = "15m"

  timeout = "30m"
}

build {
  sources = [
    "source.ibmcloud-vpc.ubuntu-focal"
  ]

  provisioner "comment" {
    comment = "GENESIS"
    ui = true
    bubble_text = true
  }
  provisioner "shell" {
    script = var.vsi_user_data_file
  }
  provisioner "ansible" {
    playbook_file = var.ansible_file
  }
  provisioner "goss" {
    tests = [
      "./goss/goss.yaml"
    ]
  }
  provisioner "comment" {
    comment = "SEUNGYEOP"
    ui = true
    bubble_text = true
  }
}
