#----------------------------------------------------------------------------
# Vaultron CUSTOM
#----------------------------------------------------------------------------

# disable_performance_standby = true

api_addr     = "${api_addr}"
cluster_addr = "${cluster_addr}"
# cluster_name = "${cluster_name}"

ui = true

listener "tcp" {
  address                  = "${address}"
  cluster_address          = "${cluster_address}"
  tls_cert_file            = "/etc/ssl/certs/vault-server.crt"
  tls_key_file             = "/etc/ssl/vault-server.key"
  tls_client_ca_file       = "/etc/ssl/certs/ca.pem"
  tls_disable_client_certs = "true"
}

#storage "raft" {
#  path = "/vault"
#  node_id = "${node_id}"
#}

storage "consul" {
  address            = "${consul_address}:8500"
  scheme             = "https"
  tls_ca_file        = "/etc/ssl/certs/ca.pem"
  token              = "b4c0ffee-3b77-04af-36d6-738b697872e6"
  path               = "vault/"
  disable_clustering = "${disable_clustering}"
  service_tags       = "${service_tags}"
}

# Plugin path
plugin_directory = "/vault/plugins"

# -----------------------------------------------------------------------
# Enable Prometheus metrics by default (eventually)
# -----------------------------------------------------------------------

# NB: The telemetry is actually controlled in `extras/vault_telemetry.hcl`
#     The following are for testing/debugging of Vaultron itself only

# telemetry {
#   # prometheus_retention_time = "30s"
#   # Below is for prometheus only
#   # disable_hostname          = false
#   dogstatsd_addr   = "10.10.42.219:8125"
#   disable_hostname = true
# }

# telemetry {
#   dogstatsd_addr   = "172.17.0.2:8125"
#   disable_hostname = true
# }
