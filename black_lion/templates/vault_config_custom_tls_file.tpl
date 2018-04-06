###
### Vaultron: Vault custom configuration file (with TLS support) FILE BACKEND
###

cluster_name = "${cluster_name }"
ui = true

listener "tcp" {
  address = "${address}"
  tls_disable = "false"
  tls_cert_file = "${tls_cert}"
  tls_key_file = "${tls_key}"
}

storage "file" {
  path = "/vault/data/vaultron"
  token = "vaultron-forms-and-eats-all-the-tacos-in-town"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

# Default TTL values
default_lease_ttl = "50000h"   # 2083 days
max_lease_ttl = "50000h"       # 2083 days

# Plugin path
plugin_directory = "/vault/plugins"

# API Address
api_addr = "https://${address}"
