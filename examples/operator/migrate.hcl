storage_source "consul" {
  address            = "127.0.0.1:8500"
  scheme             = "https"
  tls_ca_file        = "etc/tls/ca.pem"
  token              = "b4c0ffee-3b77-04af-36d6-738b697872e6"
  path               = "vault/"
  disable_clustering = "false"
  service_tags       = "vaultron"
}

storage_destination "file" {
  path = "tmp/migrate"
}
