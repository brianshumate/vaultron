{
  "service": {
    "name": "graphite-web",
    "tags": ["graphite", "vaultron"],
    "address": "",
    "port": 80,
    "enable_tag_override": false,
    "checks": [
      {
        "script": "[ $(curl -s -o /dev/null -w \"%{http_code}\" http://${statsd_ip}/) = 200 ]",
        "interval": "10s"
      }
    ]
  }
}