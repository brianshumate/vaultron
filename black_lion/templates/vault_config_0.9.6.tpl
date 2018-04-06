# Vault OSS v0.9.6

cluster_name = "${cluster_name }"

storage "consul" {
  address = "${consul_address}:8500"
  scheme = "https"
  tls_ca_file  = "/vault/config/ca-bundle.pem"
  token   = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
  tls_cert_file = "/vault/config/vault-server.crt"
  tls_key_file = "/vault/config/vault-server.key"
  tls_disable_client_certs = true
}

# Default TTL values
default_lease_ttl = "50000h"   # 2083 days
max_lease_ttl = "50000h"       # 2083 days

# Plugin path
plugin_directory = "/vault/plugins"

# statsd/graphite/grafana (Yellow Lion)
telemetry {
  statsd_address = "${statsd_ip}:8125"
}
