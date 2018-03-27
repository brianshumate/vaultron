# Vaultron CUSTOM
#----------------------------------------------------------------------------

cluster_name = "${cluster_name }"

# Default TTL values
default_lease_ttl = "168h" # 7 days
max_lease_ttl = "23976h"   # 999 days

# Plugin path
plugin_directory  = "/vault/plugins"


listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
}

storage "consul" {
  address = "${consul_address}:8500"
  token = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
  disable_clustering = "${disable_clustering}"
}


# Telemetry

# statsd
# telemetry {
#   statsd_address = "172.17.0.2:8125"
# }


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