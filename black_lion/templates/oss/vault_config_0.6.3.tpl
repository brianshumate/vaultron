# Vault OSS v0.6.3

cluster_name = "${cluster_name}"

listener "tcp" {
  address         = "${address}"
  cluster_address = "${cluster_address}"
  tls_cert_file   = "/etc/ssl/certs/vault-server.crt"
  tls_key_file    = "/etc/ssl/vault-server.key"
}

backend "consul" {
  address     = "${consul_address}:8500"
  scheme      = "https"
  tls_ca_file = "/etc/ssl/certs/ca.pem"
  path        = "vault/"
}
