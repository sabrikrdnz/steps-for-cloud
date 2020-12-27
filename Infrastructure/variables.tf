variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "ansible_node_vm_size" {
  description = "Size of ansible nodes"
  type    = string
  default = "Standard_B1s"
}

variable "resource_prefix" {
type = string
}

variable "instance_count" {
  type    = number
}

/*
variable "ssh_public_key" {
  type = string
}
*/

variable "vnet_name" {
  default = "Intertech-Az-Vnet"
  type = string
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.10.0.0/16"
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.10.1.0/24"]
}

variable "subs_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}
