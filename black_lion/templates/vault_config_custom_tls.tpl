###
### Vaultron: Vault custom configuration file (with TLS support)
###

cluster_name = "${cluster_name }"
ui = true

storage "consul" {
  address = "${consul_address}:8500"
  token = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "false"
  tls_cert_file = "${tls_cert}"
  tls_key_file = "${tls_key}"
}

# Default TTL values
default_lease_ttl = "50000h"   # 2083 days
max_lease_ttl = "50000h"       # 2083 days

# Plugin path
plugin_directory = "/vault/plugins"

# API Address
api_addr = "http://${address}"
