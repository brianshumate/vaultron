cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}
