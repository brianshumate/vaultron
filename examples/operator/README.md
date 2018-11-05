# Operator Examples

## Migrate

You can practice a migration of Vaultron data using `vault operator migrate` and the provided example configuration.

> **NOTE** if you need some quick secret data, use the example script to generate some:

```
$ ./examples/tests/gen_kv_secrets --count=10 --path=vaultron-kv
[vaultron] [@] Created KV secret at path: vaultron-kv/test/266b0648eeb844f3 id=DD3F78EB-4C39-41BE-95E7-1127DD8038C8 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/96a3a068a0edb7ec id=B8DF599C-FC2C-4DC7-89AE-F48E844322F8 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/dc45b1309d6911fe id=6A082269-F35B-499F-80E1-386BDCA73694 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/8240af5abe97c102 id=DBC1F3E4-640E-434E-A821-AEF24F6158C2 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/6788f7dffed8c4bc id=D22CAA07-03FD-4401-BBFF-1CC420640203 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/4d709dc654393b7d id=0667399E-95A8-4201-B6C4-9664B40D06D4 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/b1053a345c8b01d3 id=83FE0950-1EC5-470F-89D2-0D6662303287 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/f893e8c78420b302 id=41BD18CB-FCD0-4545-A4D3-A08B4FC2DC0D 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/dd544c8629ef9982 id=AF7504BC-1FDD-4AE8-A861-2955070E465E 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/d055e215f5f18227 id=73526046-0BEF-4425-A8CC-0735E9F26773 
[vaultron] [@] Created KV secret at path: vaultron-kv/test/53b59ffc4dc0b51d id=061B60C3-92C4-424E-8660-1ACAF36621AD 
```

Create the configuration file from the root of the vaultron project hierarchy:

```
$ cat <<MIGRATE_CONFIG > ./migrate.hcl
storage_source "consul" {
  address = "127.0.0.1:8500"
  scheme = "https"
  tls_ca_file  = "$PWD/etc/tls/ca-bundle.pem"
  token   = "vaultron-forms-and-eats-all-the-tacos-in-town"
  path = "vault/"
}

storage_destination "file" {
  path    = "$PWD/data/migration"
}
MIGRATE_CONFIG
```

Stop Vault containers:

```
$ for c in {0..2}; do docker stop "vaultron-vault$c"; done
vaultron-vault0
vaultron-vault1
vaultron-vault2
```

Migrate data:

```
$ vault operator migrate -config migrate.hcl
2018-10-30T12:05:27.734-0400 [INFO]  copied key: path=audit/e6b6c63b-45e7-7b05-4b46-420819d9df54/salt
2018-10-30T12:05:27.737-0400 [INFO]  copied key: path=core/audit
2018-10-30T12:05:27.744-0400 [INFO]  copied key: path=core/auth
2018-10-30T12:05:27.756-0400 [INFO]  copied key: path=core/cluster/local/info
2018-10-30T12:05:27.758-0400 [INFO]  copied key: path=core/keyring
2018-10-30T12:05:27.760-0400 [INFO]  copied key: path=core/local-audit
2018-10-30T12:05:27.762-0400 [INFO]  copied key: path=core/local-auth
2018-10-30T12:05:27.763-0400 [INFO]  copied key: path=core/local-mounts
2018-10-30T12:05:27.765-0400 [INFO]  copied key: path=core/master
2018-10-30T12:05:27.767-0400 [INFO]  copied key: path=core/mounts
2018-10-30T12:05:27.769-0400 [INFO]  copied key: path=core/seal-config
2018-10-30T12:05:27.774-0400 [INFO]  copied key: path=core/wrapping/jwtkey
2018-10-30T12:05:27.783-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/266b0648eeb844f3
2018-10-30T12:05:27.785-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/4d709dc654393b7d
2018-10-30T12:05:27.788-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/53b59ffc4dc0b51d
2018-10-30T12:05:27.791-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/6788f7dffed8c4bc
2018-10-30T12:05:27.793-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/8240af5abe97c102
2018-10-30T12:05:27.795-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/96a3a068a0edb7ec
2018-10-30T12:05:27.797-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/b1053a345c8b01d3
2018-10-30T12:05:27.800-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/d055e215f5f18227
2018-10-30T12:05:27.802-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/dc45b1309d6911fe
2018-10-30T12:05:27.804-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/dd544c8629ef9982
2018-10-30T12:05:27.806-0400 [INFO]  copied key: path=logical/564737ae-0e15-5712-bd47-a11e61aef103/test/f893e8c78420b302
2018-10-30T12:05:27.811-0400 [INFO]  copied key: path=sys/policy/control-group
2018-10-30T12:05:27.813-0400 [INFO]  copied key: path=sys/policy/default
2018-10-30T12:05:27.815-0400 [INFO]  copied key: path=sys/policy/response-wrapping
2018-10-30T12:05:27.822-0400 [INFO]  copied key: path=sys/token/accessor/2653ee392efbe9e68636fe9ef5f62b40709f65be
2018-10-30T12:05:27.825-0400 [INFO]  copied key: path=sys/token/id/8f34eff71bb5b1a61666d8eb44270e2988bcc3e3
2018-10-30T12:05:27.827-0400 [INFO]  copied key: path=sys/token/salt
Success! All of the keys have been migrated.
```

Verify data with separate Vault process:

```
$ cat <<VAULT_TEST_CONFIG > ./vault_test.hcl
storage "file" {
  path    = "$PWD/data/migration"
}

listener "tcp" {
  address     = "127.0.0.1:8222"
  tls_disable = 1
}
disable_mlock = true
VAULT_TEST_CONFIG
```

Start test Vault on TCP/8222 using filesystem storage with migrated data:

```
$ vault server -config=vault_test.hcl
```

In another window, attempt unseal, login, and secret access:


```
$ VAULT_ADDR=http://localhost:8222 \
vault operator unseal z4UOkGD/QumhRZKqj7t5QD0PbXwYV/jsoE0eYfzEto4=
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.0.0-beta1
Cluster Name    vaultron
Cluster ID      0c7cc07d-0cc1-6b17-ed9e-bf6cdb01b5bc
HA Enabled      false
```

```
$ VAULT_ADDR=http://localhost:8222 \
vault login 4mdQN3uqaumsMAIFMTeG9iek
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                4mdQN3uqaumsMAIFMTeG9iek
token_accessor       2rf2bAWhxfpgFjSM2KtEsmN2
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

Read secret:

```
$ VAULT_ADDR=http://localhost:8222 \
vault read vaultron-kv/test/266b0648eeb844f3
Key                 Value
---                 -----
refresh_interval    768h
id                  DD3F78EB-4C39-41BE-95E7-1127DD8038C8
```
