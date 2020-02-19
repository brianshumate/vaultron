# Vaultron Consul flavored storage

storage "consul" {
  address            = "${consul_address}:8500"
  scheme             = "https"
  tls_ca_file        = "/etc/ssl/certs/ca.pem"
  token              = "b4c0ffee-3b77-04af-36d6-738b697872e6"
  path               = "${vault_path}"
  disable_clustering = "${disable_clustering}"
  service_tags       = "${service_tags}"
}
