cluster_name = "vaultron"

storage "consul" {
  address = "172.17.0.2:8500"
  path = "vault/"
  disable_clustering = "true"
  disable_registration = "true"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "1"
}
