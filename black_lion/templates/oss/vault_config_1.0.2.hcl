# Vault OSS v1.0.2

# -----------------------------------------------------------------------
# Global configuration
# -----------------------------------------------------------------------

api_addr         = "${api_addr}"
cluster_name     = "${cluster_name}"
cluster_address  = "${cluster_address}"
log_level        = "${log_level}"
ui               = true
plugin_directory = "/vault/plugins"

# -----------------------------------------------------------------------
# Listener configuration
# -----------------------------------------------------------------------

listener "tcp" {
  address       = "${address}"
  tls_cert_file = "/etc/ssl/certs/vault-server.crt"
  tls_key_file  = "/etc/ssl/vault-server.key"
}

# -----------------------------------------------------------------------
# Storage configuration
# -----------------------------------------------------------------------

storage "consul" {
  address            = "${consul_address}:8500"
  scheme             = "https"
  tls_ca_file        = "/etc/ssl/certs/ca.pem"
  token              = "b4c0ffee-3b77-04af-36d6-738b697872e6"
  path               = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags       = "${service_tags}"
}

# -----------------------------------------------------------------------
# Optional cloud seal configuration
# -----------------------------------------------------------------------

# GCPKMS

