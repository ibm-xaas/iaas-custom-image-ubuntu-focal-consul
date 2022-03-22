variable "region" {
  description = "Region name"
  default     = "us-east"
}

variable "prefix" {
  default     = "prefix"
  description = "The prefix string"
}

variable "ibm_resource_group" {
  default     = "Default"
  description = "IBM Cloud resource group name"
}
variable "total_ipv4_address_count" {
  description = "IBM total address count"
  default     = 256
}

variable "profile" {
  default = "cx2-2x4"
}
variable "image_name" {
  default = "ubuntu-focal-docker-consul"
}

variable "image_version" {
  default = "0-1-0"
  # goss was added
}
