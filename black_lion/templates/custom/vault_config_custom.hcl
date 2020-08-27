#----------------------------------------------------------------------------
# Vaultron CUSTOM base configuration
#----------------------------------------------------------------------------

# for debug only
# raw_storage_endpoint = true
# disable_performance_standby = true

api_addr         = "${api_addr}"
cluster_addr     = "${cluster_addr}"
# cluster_name   = "${cluster_name}"
disable_mlock    = "${disable_mlock}"
ui               = true

listener "tcp" {
  address            = "${address}"
  cluster_address    = "${cluster_address}"
  tls_cert_file      = "/etc/ssl/certs/vault-server.crt"
  tls_key_file       = "/etc/ssl/vault-server.key"
  tls_client_ca_file = "/etc/ssl/certs/ca.pem"
}

# Plugin path
plugin_directory = "/vault/plugins"

# -----------------------------------------------------------------------
# Enable Prometheus metrics by default
# -----------------------------------------------------------------------

# telemetry {
#   prometheus_retention_time = "30s"
#   disable_hostname          = false
# }

# NB: The telemetry is actually controlled in `extras/vault_telemetry.hcl`
#     The following are for testing/debugging of Vaultron itself only

# telemetry {
# dogstatsd_addr   = "172.17.0.2:8125"
# prometheus_retention_time = "30s"
# Below is for prometheus only
# disable_hostname = false
# }
