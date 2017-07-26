###
### Vaultron: Vault Open Source Version 0.7.3 configuration file
###
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
}
