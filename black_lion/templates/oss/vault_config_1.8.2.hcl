# Vault OSS v1.8.2

# -----------------------------------------------------------------------
# Global configuration
# -----------------------------------------------------------------------

api_addr         = "${api_addr}"
cluster_name     = "${cluster_name}"
cluster_address  = "${cluster_address}"
disable_mlock    = "${disable_mlock}"
log_level        = "${log_level}"
ui               = true
plugin_directory = "/vault/plugins"

# -----------------------------------------------------------------------
# Listener configuration
# -----------------------------------------------------------------------

listener "tcp" {
  address       = "${address}"
  tls_cert_file = "/etc/ssl/certs/vault-server.crt"
  tls_key_file  = "/etc/ssl/vault-server.key"
}

# -----------------------------------------------------------------------
# Enable Prometheus metrics by default
# -----------------------------------------------------------------------

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname          = false
}
