# Import CAs

To import and reconfigure CAs on a new Vaultron, do these steps or use `eyebeams_tls`:

### Tune Root CA

```
$ vault secrets tune \
  -max-lease-ttl=50000h \
  vaultron-root-pki
Success! Tuned the secrets engine at: vaultron-root-pki/
```

### Import Root CA

```
$ vault write \
  vaultron-root-pki/config/ca \
  pem_bundle=@examples/tls/vaultron-root-ca-bundle.pem
Success! Data written to: vaultron-root-pki/config/ca
```

### Configure URLs

```
$ vault write vaultron-root-pki/config/urls \
  issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
  crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"
Success! Data written to: vaultron-root-pki/config/urls
```

### Configure Role

This Root CA role provides for generating certificates with a maximum **1750 day lifespan**:

```
$ vault write vaultron-root-pki/roles/vaultron-consul-root \
  allow_localhost=true \
  allowed_domains=arus.consul,sura.consul \
  allow_subdomains=true \
  allow_bare_domains=true \
  allow_glob_domains=true \
  allow_ip_sans=true \
  generate_lease=true \
  organization="Vaultron Lab" \
  country="United States of America" \
  locality="Kittyhawk" \
  province="Outer Banks" \
  max_ttl=42000h
Success! Data written to: vaultron-root-pki/roles/vaultron-consul-root
```

### Tune Intermediate CA

Tune the Intermediate CA secrets engine mount:

```
$ vault secrets tune \
  -max-lease-ttl=50000h \
  vaultron-int-pki
Success! Tuned the secrets engine at: vaultron-int-pki/
```

### Import Intermediate CA

```
$ vault write \
  vaultron-int-pki/config/ca \
  pem_bundle=@examples/tls/vaultron-int-ca-bundle.pem
Success! Data written to: vaultron-int-pki/config/ca
```

### Sign Intermediate CA with Root CA

set the intermediate certificate authority's signing certificate to the root-signed certificate:

```
$ vault write \
  vaultron-int-pki/intermediate/set-signed \
  certificate=@examples/tls/vaultron-intermediate-signed.pem
Success! Data written to: vaultron-int-pki/intermediate/set-signed
```

### Configure URLs

```
$ vault write \
  vaultron-int-pki/config/urls \
  issuing_certificates="http://127.0.0.1:8200/v1/pki_int/ca" \
  crl_distribution_points="http://127.0.0.1:8200/v1/pki_int/crl"
Success! Data written to: vaultron-int-pki/config/urls
```

### Configure a Role

The role has a maximum TTL of 1750 days:

```
$ vault write vaultron-int-pki/roles/vaultron-int \
  allow_subdomains=true \
  allowed_domains=arus.consul,node.arus.consul,node.sura.consul,node.consul,service.consul \
  allow_bare_domains=true \
  allow_glob_domains=true \
  allow_ip_sans=true \
  allow_localhost="true" \
  generate_lease=true \
  organization="Vaultron Lab" \
  country="United States of America" \
  locality="Kittyhawk" \
  province="Outer Banks" \
  max_ttl=42000h \
  ttl=42000h
Success! Data written to: vaultron-int-pki/roles/vaultron-int
```

#### Issue Certificate

For example, a 7 day client authentication certificate:

```
vault write vaultron-int-pki/issue/vaultron-int \
  common_name=client-auth.node.arus.consul \
  alt_names=client-auth.node.consul,server.arus.consul,localhost \
  ip_sans="127.0.0.1,172.17.0.1,172.17.0.2,172.17.0.3,172.17.0.4,172.17.0.5,172.17.0.6,172.17.0.7,172.17.0.8,172.17.0.9,172.17.0.10,172.17.0.11,172.17.0.12,172.17.0.13,172.17.0.14,172.17.0.15,172.17.0.16,172.17.0.17,172.17.0.18,172.17.0.19,172.17.0.20,100.115.92.200,100.115.92.201,100.115.92.202,100.115.92.203,100.115.92.204,100.115.92.205,100.115.92.206,100.115.92.207,100.115.92.208,100.115.92.209,100.115.92.210,100.115.92.211,100.115.92.212,100.115.92.213,100.115.92.214,100.115.92.215,100.115.92.216,100.115.92.217,100.115.92.218,100.115.92.219,100.115.92.220" \
  ttl=168h
```
