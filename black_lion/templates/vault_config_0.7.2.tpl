# Vault OSS v0.7.2

cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
  tls_cert_file = "/vault/config/vault-server.crt"
  tls_key_file = "/vault/config/vault-server.key"
  tls_disable_client_certs = true
}
