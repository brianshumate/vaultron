# Vaultron Yellow Lion

telemetry {
  dogstatsd_addr   = "${statsd_ip}:8125"
  disable_hostname = true
  # Below is for prometheus only
  # prometheus_retention_time = "30s"
  # disable_hostname          = false
}
