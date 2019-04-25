# TLS Auth Method

Vaultron will enable a `vaultron-cert` Auth Method if you use `blazing_sword` and this guide presumes that the Auth Method is available there.

## Certificate?

Use the Vaultron Intermediate CA certificate for configuring TLS Auth Method.

## Configure

Create a vaultron 42 hour token configuration as an example:

```
$ pwd
vaultron/examples/tls
$ vault write auth/vaultron-cert/certs/vaultron-42-hour \
    display_name=vaultron \
    policies=wildcard \
    certificate=@ca.pem \
    ttl=42h
Success! Data written to: auth/vaultron-cert/certs/vaultron-42-hour
```

## Get a Certificte

Use the Intermediate CA to get a client cert and key:

```
vault write vaultron-int-pki/issue/vaultron-int \
  common_name=client-auth.node.arus.consul \
  alt_names=client-auth.node.consul,server.arus.consul,localhost \
  ip_sans="127.0.0.1,172.17.0.1,172.17.0.2,172.17.0.3,172.17.0.4,172.17.0.5,172.17.0.6,172.17.0.7,172.17.0.8,172.17.0.9,172.17.0.10,172.17.0.11,172.17.0.12,172.17.0.13,172.17.0.14,172.17.0.15,172.17.0.16,172.17.0.17,172.17.0.18,172.17.0.19,172.17.0.20,100.115.92.200,100.115.92.201,100.115.92.202,100.115.92.203,100.115.92.204,100.115.92.205,100.115.92.206,100.115.92.207,100.115.92.208,100.115.92.209,100.115.92.210,100.115.92.211,100.115.92.212,100.115.92.213,100.115.92.214,100.115.92.215,100.115.92.216,100.115.92.217,100.115.92.218,100.115.92.219,100.115.92.220" \
  ttl=168h \
  -format=json \
  | jq -r '.data.certificate + "\n" + .data.private_key' \
  | awk '/CERTIFICATE/ {out="client-cert.pem"} /RSA/ {out="client-key.pem"} { print > out }'
```

## Login for a 42 Hour Token!

```
$ vault login \
  -method=cert \
  -path=vaultron-cert \
  -ca-cert=ca.pem \
  -client-cert=client-cert.pem \
  -client-key=client-key.pem \
  name=vaultron-42-hour
```