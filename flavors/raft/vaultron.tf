# =======================================================================
# Vaultron: Terraformed, Raft-backed, Vault on Docker for Linux & macOS
# =======================================================================

terraform {
  required_version = ">= 0.13"
}

# -----------------------------------------------------------------------
# Version variables
# -----------------------------------------------------------------------

# Set TF_VAR_vault_version to override this
variable "vault_version" {
  default = "1.8.3"
}

# -----------------------------------------------------------------------
# Global variables
# -----------------------------------------------------------------------

terraform {
  backend "local" {
    path = "tfstate/terraform.tfstate"
  }
}

# Set TF_VAR_docker_host to override this
# tcp with hostname example:
# export TF_VAR_docker_host="tcp://docker:2345"
variable "docker_host" {
  default = "unix:///var/run/docker.sock"
}

# Set TF_VAR_datacenter_name to override this
variable "datacenter_name" {
  default = "arus"
}

# Set TF_VAR_secondary_datacenter_name to override this
variable "secondary_datacenter_name" {
  default = "sura"
}

# -----------------------------------------------------------------------
# Global configuration
# -----------------------------------------------------------------------

provider "docker" {
  host = var.docker_host
}

# -----------------------------------------------------------------------
# Vault variables
# -----------------------------------------------------------------------

# Set TF_VAR_vault_license to override this
variable "vault_license" {
  default = ""
}

# Set TF_VAR_vault_flavor to override this
variable "vault_flavor" {
  default = "raft"
}

# Set TF_VAR_vault_ent_id to override this
variable "vault_ent_id" {
  default = "vault:latest"
}

# Set TF_VAR_vault_server_log_format to override this
variable "vault_server_log_format" {
  default = "standard"
}

# Set TF_VAR_vault_server_log_level to override this
variable "vault_server_log_level" {
  default = "debug"
}

# Set TF_VAR_vault_path to override this
variable "vault_path" {
  default = "vault"
}

# Set TF_VAR_vault_raft_path to override this
variable "vault_raft_path" {
  default = "/vault/data"
}

# Set TF_VAR_vault_cluster_name to override this
variable "vault_cluster_name" {
  default = "vaultron"
}

# Set TF_VAR_disable_clustering to override this
variable "disable_clustering" {
  default = "false"
}

# Set TF_VAR_vault_oss_instance_count to override this
variable "vault_oss_instance_count" {
  default = "3"
}

# Set TF_VAR_vault_custom_instance_count to override this
variable "vault_custom_instance_count" {
  default = "0"
}

# Set TF_VAR_vault_custom_config_template to override this
variable "vault_custom_config_template" {
  default = "vault_config_custom.hcl"
}

# Set TF_VAR_vault_disable_mlock to override this
# NB: mlock should not be enabled when using Raft based integrated storage
variable "vault_disable_mlock" {
  default = true
}

# -----------------------------------------------------------------------
# Telemetry variables
# -----------------------------------------------------------------------

# Set TF_VAR_vaultron_telemetry_count to override this (either 0 or 1)
variable "vaultron_telemetry_count" {
  default = "0"
}

# Set TF_VAR_grafana_version to override this
variable "grafana_version" {
  default = "latest"
}

# Set TF_VAR_statsd_version to override this
variable "statsd_version" {
  default = "latest"
}

# Set TF_VAR_statsd_ip to override this
variable "statsd_ip" {
  default = "127.0.0.1"
}

# -----------------------------------------------------------------------
# Sidecar variables
# -----------------------------------------------------------------------

# Set TF_VAR_vaultron_sidecar_instance_count to override this
variable "vaultron_sidecar_instance_count" {
  default = "0"
}


# -----------------------------------------------------------------------
# Module definitions
# -----------------------------------------------------------------------

module "telemetry" {
  source                   = "../../yellow_lion"
  grafana_version          = var.grafana_version
  statsd_ip                = var.statsd_ip
  statsd_version           = var.statsd_version
  vaultron_telemetry_count = var.vaultron_telemetry_count
}

#module "sidecar" {
#  source = "../../blue_lion"
#}

module "vaultron" {
  source                       = "../../black_lion"
  datacenter_name              = var.datacenter_name
  vault_cluster_name           = var.vault_cluster_name
  vault_custom_config_template = var.vault_custom_config_template
  vault_custom_instance_count  = var.vault_custom_instance_count
  vault_disable_mlock          = var.vault_disable_mlock
  vault_ent_id                 = var.vault_ent_id
  vault_oss_instance_count     = var.vault_oss_instance_count
  vault_path                   = var.vault_path
  vault_raft_path              = var.vault_raft_path
  vault_server_log_format      = var.vault_server_log_format
  vault_server_log_level       = var.vault_server_log_level
  vault_flavor                 = var.vault_flavor
  vault_version                = var.vault_version
  vault_license                = var.vault_license
  vaultron_telemetry_count     = var.vaultron_telemetry_count
  statsd_ip                    = module.telemetry.statsd_ip
  # XXX: sad... will fix later
  consul_server_ips  = ["10.10.42.200", "10.10.42.201", "10.10.42.202"]
  consul_client_ips  = ["10.10.42.200", "10.10.42.201", "10.10.42.202"]
  disable_clustering = false
}
