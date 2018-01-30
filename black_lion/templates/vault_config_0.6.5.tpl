# Vault OSS v0.6.5

cluster_name = "${cluster_name }"

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

backend "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
}
