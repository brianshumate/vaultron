# Vault OSS v0.6.5

cluster_name = "${cluster_name }"

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "${tls_disable}"
  tls_cert_file = "/vault/config/vault-server.crt"
  tls_key_file = "/vault/config/vault-server.key"
  tls_disable_client_certs = true
}

backend "consul" {
  address = "${consul_address}:8500"
  scheme = "https"
  path = "vault/"
}
