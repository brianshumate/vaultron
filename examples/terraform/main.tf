# =======================================================================
# Terraform Vault Provider example configuration
#
# NB: This configuration performs all of the same post-unseal steps that
#     `blazing_sword` performs.
#
# - Establish a file based audit log device resource
# -
# ========================================================================

provider "vault" {

}

# -----------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------

variable "datacenter_name" {
  default = "arus"
}

# -----------------------------------------------------------------------
# Audit Device Resources
# -----------------------------------------------------------------------

resource "vault_audit" "vaultron_audit_device" {
  type = "file"

  options = {
    file_path = "/vault/logs/audit.log"
    description = "Socket device by Vaultron and Terraform Vault provider"
  }
}

# -----------------------------------------------------------------------
# Auth Method Resources
# -----------------------------------------------------------------------

resource "vault_auth_backend" "vaultron_approle" {
  type = "approle"
  path = "vaultron-approle"
  description = "AppRole auth method by Vaultron and Terraform Vault provider"
}

resource "vault_auth_backend" "vaultron_cert" {
  type = "cert"
  path = "vaultron-cert"
  description = "X.509 certificate auth method by Vaultron and Terraform Vault provider"
}

resource "vault_auth_backend" "vaultron_userpass" {
  type = "userpass"
  path = "vaultron-userpass"
  description = "Username and password auth method by Vaultron and Terraform Vault provider"
}

resource "vault_auth_backend" "vaultron_ldap" {
  type = "ldap"
  path = "vaultron-ldap"
  description = "LDAP auth method by Vaultron and Terraform Vault provider"
}


# -----------------------------------------------------------------------
# Secrets Engines Resources
# -----------------------------------------------------------------------

resource "vault_mount" "vaultron_kv" {
  path        = "vaultron-kv"
  type        = "kv"
  description = "KV version 1 Secrets Engine by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_aws" {
  path        = "vaultron-aws"
  type        = "aws"
  description = "AWS Secrets Engine by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_consul" {
  path        = "vaultron-consul"
  type        = "consul"
  description = "Consul Secrets Engine by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_pki_root" {
  path        = "vaultron-root-pki"
  type        = "pki"
  description = "PKI Secrets Engine (root CA) by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_pki_int" {
  path        = "vaultron-root-int"
  type        = "pki"
  description = "PKI Secrets Engine (int CA) by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_transit" {
  path        = "vaultron-transit"
  type        = "transit"
  description = "Transit Secrets Engine by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_ssh_host_signer" {
  path        = "vaultron-ssh-host-signer"
  type        = "ssh"
  description = "SSH Secrets Engine (host) by Vaultron and Terraform Vault provider"
}

resource "vault_mount" "vaultron_ssh_client_signer" {
  path        = "vaultron-ssh-client-signer"
  type        = "ssh"
  description = "SSH Secrets Engine (client) by Vaultron and Terraform Vault provider"
}
