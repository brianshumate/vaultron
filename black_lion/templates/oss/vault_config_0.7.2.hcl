# Vault OSS v0.7.2

cluster_name = "${cluster_name}"

listener "tcp" {
  address         = "${address}"
  cluster_address = "${cluster_address}"
  tls_cert_file   = "/etc/ssl/certs/vault-server.crt"
  tls_key_file    = "/etc/ssl/vault-server.key"
}
