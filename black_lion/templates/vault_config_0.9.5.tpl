# Vault OSS v0.9.5

cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  token   = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}

# Default TTL values
default_lease_ttl = "168h" # 7 days
max_lease_ttl = "23976h"   # 999 days

# Plugin path
plugin_directory  = "/vault/plugins"
