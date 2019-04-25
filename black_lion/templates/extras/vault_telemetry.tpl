# Yellow Lion

telemetry {
    disable_hostname = false
    prometheus_retention_time = "30s"
    statsd_address = "${statsd_ip}:8125"
}
