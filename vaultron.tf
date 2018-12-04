# =======================================================================
# Vaultron: A Terraformed, Consul-backed, Vault on Docker for Linux or macOS
# =======================================================================

# -----------------------------------------------------------------------
# Version variables
# -----------------------------------------------------------------------

# Set TF_VAR_vault_version to set this
variable "vault_version" {
  default = "1.0.0"
}

# Set TF_VAR_consul_version to set this
variable "consul_version" {
  default = "1.4.0"
}

# -----------------------------------------------------------------------
# Global variables
# -----------------------------------------------------------------------

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
  default = "arus"
}

# Set TF_VAR_secondary_datacenter_name to set this
variable "secondary_datacenter_name" {
  default = "sura"
}

# -----------------------------------------------------------------------
# Vault variables
# -----------------------------------------------------------------------

# Set TF_VAR_use_vault_oss to set this
variable "use_vault_oss" {
  default = "1"
}

# Set TF_VAR_vault_ent_id to set this
variable "vault_ent_id" {
  default = "vault:latest"
}

# Set TF_VAR_vault_path to set this
variable "vault_path" {
  default = "vault"
}

# Set TF_VAR_vault_cluster_name to set this
variable "vault_cluster_name" {
  default = "vaultron"
}

# Set TF_VAR_disable_clustering to set this
variable "disable_clustering" {
  default = "false"
}

# Set TF_VAR_vault_oss_instance_count to set this
variable "vault_oss_instance_count" {
  default = "3"
}

# Set TF_VAR_vault_custom_instance_count to set this
variable "vault_custom_instance_count" {
  default = "0"
}

# Set TF_VAR_vault_custom_config_template to set this
variable "vault_custom_config_template" {
  default = "vault_config_custom.tpl"
}

# Set TF_VAR_vault_server_log_level to set this
variable "vault_server_log_level" {
  default = "debug"
}

# -----------------------------------------------------------------------
# Consul variables
# -----------------------------------------------------------------------

# Set TF_VAR_consul_log_level to set this
variable "consul_log_level" {
  default = "debug"
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

# Set TF_VAR_consul_oss to set this
variable "consul_oss" {
  default = "1"
}

# Set TF_VAR_consul_oss_instance_count to set this
variable "consul_oss_instance_count" {
  default = "3"
}

# Set TF_VAR_consul_oss to set this
variable "consul_custom" {
  default = "0"
}

# Set TF_VAR_consul_custom_instance_count to set this
variable "consul_custom_instance_count" {
  default = "0"
}

# -----------------------------------------------------------------------
# Telemetry variables
# -----------------------------------------------------------------------

# Set TF_VAR_vaultron_telemetry_count to set this (either 0 or 1)
variable "vaultron_telemetry_count" {
  default = "0"
}

# Set TF_VAR_grafana_version to set this
variable "grafana_version" {
  default = "latest"
}

# Set TF_VAR_statsd_version to set this
variable "statsd_version" {
  default = "latest"
}

# Set TF_VAR_statsd_ip to set this
variable "statsd_ip" {
  default = "127.0.0.1"
}

# -----------------------------------------------------------------------
# Module definitions
# -----------------------------------------------------------------------

module "telemetry" {
  source                       = "yellow_lion"
  grafana_version              = "${var.grafana_version}"
  statsd_ip                    = "${var.statsd_ip}"
  statsd_version               = "${var.statsd_version}"
  vaultron_telemetry_count     = "${var.vaultron_telemetry_count}"
}

module "consul_cluster" {
  source                       = "red_lion"
  consul_acl_datacenter        = "${var.consul_acl_datacenter}"
  consul_custom                = "${var.consul_custom}"
  consul_custom_instance_count = "${var.consul_custom_instance_count}"
  consul_data_dir              = "${var.consul_data_dir}"
  consul_ent_id                = "${var.consul_ent_id}"
  consul_log_level             = "${var.consul_log_level}"
  consul_recursor_1            = "${var.consul_recursor_1}"
  consul_recursor_2            = "${var.consul_recursor_2}"
  consul_oss                   = "${var.consul_oss}"
  consul_oss_instance_count    = "${var.consul_oss_instance_count}"
  consul_version               = "${var.consul_version}"
  datacenter_name              = "${var.datacenter_name}"
  use_consul_oss               = "${var.use_consul_oss}"
}

module "vaultron" {
  source                       = "black_lion"
  datacenter_name              = "${var.datacenter_name}"
  consul_server_ips            = ["${module.consul_cluster.consul_oss_server_ips}"]
  consul_client_ips            = ["${module.consul_cluster.consul_client_ips}"]
  disable_clustering           = "${var.disable_clustering}"
  use_vault_oss                = "${var.use_vault_oss}"
  vault_cluster_name           = "${var.vault_cluster_name}"
  vault_custom_config_template = "${var.vault_custom_config_template}"
  vault_custom_instance_count  = "${var.vault_custom_instance_count}"
  vault_ent_id                 = "${var.vault_ent_id}"
  vault_oss_instance_count     = "${var.vault_oss_instance_count}"
  vault_path                   = "${var.vault_path}"
  vault_server_log_level       = "${var.vault_server_log_level}"
  vault_version                = "${var.vault_version}"
  vaultron_telemetry_count     = "${var.vaultron_telemetry_count}"
  statsd_ip                    = "${module.telemetry.statsd_ip}"
}
