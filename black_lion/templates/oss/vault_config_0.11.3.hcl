# Vault OSS v0.11.3

# Enable reloadable log level
log_level = "${log_level}"

api_addr     = "${api_addr}"
cluster_name = "${cluster_name}"
ui           = true

listener "tcp" {
  address                  = "${address}"
  cluster_address          = "${cluster_address}"
  tls_cert_file            = "/etc/ssl/certs/vault-server.crt"
  tls_key_file             = "/etc/ssl/vault-server.key"
  tls_disable_client_certs = "true"
}

storage "consul" {
  address            = "${consul_address}:8500"
  scheme             = "https"
  tls_ca_file        = "/etc/ssl/certs/ca.pem"
  token              = "b4c0ffee-3b77-04af-36d6-738b697872e6"
  path               = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags       = "${service_tags}"
}

# Default TTL values
default_lease_ttl = "50000h" # 2083 days
max_lease_ttl     = "50000h" # 2083 days

# Plugin path
plugin_directory = "/vault/plugins"
