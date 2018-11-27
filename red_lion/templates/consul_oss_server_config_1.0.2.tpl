{
  "bootstrap_expect": 3,
  "datacenter": "${datacenter}",
  "data_dir": "${data_dir}",
  "raft_protocol": 3,
  "acl_datacenter": "arus",
  "acl_master_token": "vaultron-forms-and-eats-all-the-tacos-in-town",
  "acl_default_policy": "allow",
  "acl_down_policy": "allow",
  "recursors": [
    "${recursor1}",
    "${recursor2}"
  ],
  "cert_file": "/etc/ssl/certs/consul-server.crt",
  "key_file": "/etc/ssl/consul-server.key",
  "ca_file": "/etc/ssl/certs/ca-bundle.pem",
  "ports": {
    "http": -1,
    "https": 8500
  },
  "ui": true
}