# =======================================================================
# Terraform Vault Provider example configuration
#
# NB: This Terraform configuration performs all post-unseal setup
#     See README.md for more details
# ========================================================================

# We presume Vault at https://localhost:8200
# and the presence of ~/.vault-token here.

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
    description = "Vaultron example file audit device"
  }
}

# -----------------------------------------------------------------------
# Auth Method Resources
# -----------------------------------------------------------------------

resource "vault_auth_backend" "vaultron_approle" {
  type = "approle"
  path = "vaultron-approle"
  description = "Vaultron example AppRole auth method"
}

resource "vault_auth_backend" "vaultron_cert" {
  type = "cert"
  path = "vaultron-cert"
  description = "Vaultron example X.509 certificate auth method"
}

resource "vault_auth_backend" "vaultron_userpass" {
  type = "userpass"
  path = "vaultron-userpass"
  description = "Vaultron example Username and password auth method"
}

resource "vault_auth_backend" "vaultron_ldap" {
  type = "ldap"
  path = "vaultron-ldap"
  description = "Vaultron example LDAP auth method"
}


# -----------------------------------------------------------------------
# Secrets Engines Resources
# -----------------------------------------------------------------------

resource "vault_mount" "vaultron_kv" {
  path        = "vaultron-kv"
  type        = "kv"
  description = "Vaultron example KV version 1 secrets engine"
}

resource "vault_mount" "vaultron_aws" {
  path        = "vaultron-aws"
  type        = "aws"
  description = "Vaultron example AWS secrets engine"
}

resource "vault_mount" "vaultron_consul" {
  path        = "vaultron-consul"
  type        = "consul"
  description = "Vaultron example Consul secrets engine"
}

resource "vault_mount" "vaultron_pki_root" {
  path        = "vaultron-root-pki"
  type        = "pki"
  description = "Vaultron example PKI secrets engine (for root CA)"
}

resource "vault_mount" "vaultron_pki_int" {
  path        = "vaultron-root-int"
  type        = "pki"
  description = "Vaultron example PKI secrets engine (for int CA)"
}

resource "vault_mount" "vaultron_transit" {
  path        = "vaultron-transit"
  type        = "transit"
  description = "Vaultron example Transit secrets engine"
}

resource "vault_mount" "vaultron_ssh_host_signer" {
  path        = "vaultron-ssh-host-signer"
  type        = "ssh"
  description = "Vaultron example SSH Secrets Engine (host)"
}

resource "vault_mount" "vaultron_ssh_client_signer" {
  path        = "vaultron-ssh-client-signer"
  type        = "ssh"
  description = "Vaultron example SSH Secrets Engine (client)"
}


# -----------------------------------------------------------------------
# Policy Resources
# -----------------------------------------------------------------------

resource "vault_policy" "vaultron_wildcard" {
  name = "wildcard"
  policy = <<EOT
// Vaultron example policy: "vaultron-wildcard"
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "vaultron_example_root_ns" {
  name = "vaultron-example-root-ns"
  policy = <<EOT
// Vaultron example policy: "example root namespace"
# Manage namespaces

path "sys/namespaces/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies via API
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage policies via CLI
path "sys/policy/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List policies via CLI
path "sys/policy" {
  capabilities = ["read", "update", "list"]
}

# Enable and manage secrets engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# List available secret engines
path "sys/mounts" {
  capabilities = [ "read" ]
}

# Create and manage entities and groups
path "identity/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Manage tokens
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "vaultron_example_ns" {
  name = "vaultron-example-ns"
  policy = <<EOT
// Vaultron example policy: "example vaultron namespace"
path "sys/namespaces/vaultron/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}
