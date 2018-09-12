# Yellow Lion

telemetry {
    statsd_address = "${statsd_ip}:8125"
    disable_hostname = false
    disable_hostname_label = true
    disable_service_label = true
    #allowed_labels = ""
    blocked_labels = "consul."
}
