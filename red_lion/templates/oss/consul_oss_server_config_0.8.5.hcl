{
  "bootstrap_expect": 3,
  "datacenter": "${datacenter}",
  "data_dir": "${data_dir}",
  "raft_protocol": 3,
  "acl_datacenter": "arus",
  "acl_master_token": "b4c0ffee-3b77-04af-36d6-738b697872e6",
  "acl_enforce_version_8": false,
  "acl_default_policy": "allow",
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
