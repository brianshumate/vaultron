#############################################################################
## Vaultron: A Terraformed, Consul-backed, Vault server on Docker for macOS
#############################################################################

###
### Global variables
###
terraform {
  backend "local" {
    path = "tfstate/terraform.tfstate"
  }
}

# "This is fine"
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Set TF_VAR_datacenter_name to set this
variable "datacenter_name" {
  default ="arus"
}

###
### Vault related variables
###
# Set TF_VAR_vault_version to set this
variable "vault_version" {
  default = "0.7.3"
}

# Set TF_VAR_use_vault_oss to set this
variable "use_vault_oss" {
  default = "1"
}

# Set TF_VAR_vault_ent_id to set this
variable "vault_ent_id" {
  default = ""
}

# Set TF_VAR_vault_path to set this
variable "vault_path" {
  default = "vault"
}

# Set TF_VAR_vault_cluster_name to set this
variable "vault_cluster_name" {
  default = "vaultron"
}

# Set TF_VAR_vault_plus_one_port to set this
variable "vault_plus_one_port" {
  default = "8301"
}

# Set TF_VAR_disable_clustering to set this
variable "disable_clustering" {
  default = "false"
}

###
### Consul related variables
###
# Set TF_VAR_consul_version to set this
variable "consul_version" {
  default = "0.9.0"
}

# Set TF_VAR_use_consul_oss to set this
variable "use_consul_oss" {
  default = "1"
}

# Set TF_VAR_consul_ent_id to set this
variable "consul_ent_id" {
  default = ""
}

# Set TF_VAR_consul_recursor_1 to set this
variable "consul_recursor_1" {
  default = "84.200.69.80"
}

# Set TF_VAR_consul_recursor_2 to set this
variable "consul_recursor_2" {
  default = "84.200.70.40"
}

# Set TF_VAR_consul_acl_datacenter to set this
variable "consul_acl_datacenter" {
  default = "arus"
}

# Set TF_VAR_consul_data_dir to set this
variable "consul_data_dir" {
  default = "/consul/data"
}

module "consul_cluster" {
  source = "red_lion"
  datacenter_name = "${var.datacenter_name}"
  consul_version = "${var.consul_version}"
  use_consul_oss = "${var.use_consul_oss}"
  consul_ent_id = "${var.consul_ent_id}"
  consul_recursor_1 = "${var.consul_recursor_1}"
  consul_recursor_2 = "${var.consul_recursor_2}"
  consul_acl_datacenter = "${var.consul_acl_datacenter}"
  consul_data_dir = "${var.consul_data_dir}"
}

module "vaultron" {
  source = "black_lion"
  datacenter_name = "${var.datacenter_name}"
  vault_version = "${var.vault_version}"
  use_vault_oss = "${var.use_vault_oss}"
  vault_ent_id = "${var.vault_ent_id}"
  vault_path = "${var.vault_path}"
  vault_cluster_name = "${var.vault_cluster_name}"
  vault_plus_one_port = "${var.vault_plus_one_port}"
  disable_clustering = "${var.disable_clustering}"
  consul_server_1_ip = "${module.consul_cluster.consul_oss_server_1_ip}"
  consul_server_2_ip = "${module.consul_cluster.consul_oss_server_2_ip}"
  consul_server_3_ip = "${module.consul_cluster.consul_oss_server_3_ip}"
  consul_client_2_ip = "${module.consul_cluster.consul_oss_client_2_ip}"
  consul_client_3_ip = "${module.consul_cluster.consul_oss_client_3_ip}"
}
