{
  "check": {
    "id": "graphite-api",
    "name": "HTTP API on Graphite port 80",
    "http": "http://${statsd_ip}/",
    "tls_skip_verify": false,
    "method": "GET",
    "header": {"x-agent":["Consul Health", "Vaultron"]},
    "interval": "10s",
    "timeout": "1s"
  }
}