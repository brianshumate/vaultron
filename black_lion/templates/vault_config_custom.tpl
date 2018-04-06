# Vaultron CUSTOM
#----------------------------------------------------------------------------

cluster_name = "${cluster_name }"

listener "tcp" {
  address = "${address}"
  tls_disable = "false"
  tls_cert_file = "${tls_cert}"
  tls_key_file = "${tls_key}"
}

storage "consul" {
  address = "${consul_address}:8500"
  scheme = "https"
  tls_ca_file  = "/vault/config/ca-bundle.pem"
  token   = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags = "${service_tags}"
}

# Default TTL values
default_lease_ttl = "50000h"   # 2083 days
max_lease_ttl = "50000h"       # 2083 days

# Plugin path
plugin_directory = "/vault/plugins"

# Telemetry

# statsd/graphite/grafana (Yellow Lion)
telemetry {
  statsd_address = "${statsd_ip}:8125"
}

# dogstatsd
# telemetry {
#   dogstatsd_addr  = "172.17.0.2:8125"
#   dogstatsd_tags  = [ "datacenter:arus"]
# }

# HA configuration
#----------------------------------------------------------------------------

# API Address
# api_addr = "http://${address}"

# Cluster Address
#