# Vaultron CUSTOM
#----------------------------------------------------------------------------

cluster_name = "${cluster_name }"
ui = true

listener "tcp" {
  address = "${address}"
  tls_disable = "${tls_disable}"
  tls_cert_file = "/etc/ssl/certs/vault-server.crt"
  tls_key_file = "/etc/ssl/vault-server.key"
  # tls_disable_client_certs = true
  # proxy_protocol_behavior = "allow_authorized"
  # proxy_protocol_authorized_addrs = "172.17.0.0/24"
}


storage "consul" {
  address = "${consul_address}:8500"
  scheme = "https"
  tls_ca_file  = "/etc/ssl/certs/ca-bundle.pem"
  token   = "b4c0ffee-3b77-04af-36d6-738b697872e6"
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

# telemetry {
#    statsd_address = "${statsd_ip}:8125"
#}

# telemetry {
#   dogstatsd_addr  = "172.17.0.2:8125"
#   dogstatsd_tags  = [ "datacenter:arus"]
# }
