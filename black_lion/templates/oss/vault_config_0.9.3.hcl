# Vault OSS v0.9.3

api_addr     = "${api_addr}"
cluster_name = "${cluster_name}"

listener "tcp" {
  address         = "${address}"
  cluster_address = "${cluster_address}"
  tls_cert_file   = "/etc/ssl/certs/vault-server.crt"
  tls_key_file    = "/etc/ssl/vault-server.key"
}

# Plugin path
plugin_directory = "/vault/plugins"
