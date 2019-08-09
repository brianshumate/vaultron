{
  "acl_enforce_version_8": false,
  "bootstrap_expect": 3,
  "datacenter": "${datacenter}",
  "data_dir": "${data_dir}",
  "disable_host_node_id": true,
  "recursors": [
    "${recursor1}",
    "${recursor2}"
  ],
  "cert_file": "/etc/ssl/certs/consul-server.crt",
  "key_file": "/etc/ssl/consul-server.key",
  "ca_file": "/etc/ssl/certs/ca.pem",
  "ports": {
    "http": -1,
    "https": 8500
  },
  "ui": true
}
