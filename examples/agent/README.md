# Vault Agent

Some simple examples for using Vault Agent with Vaultron


## AppRole Auto Auth Configuration Example

Using the following AppRole for Agent auto-auth:

```
$ vault write auth/vaultron-approle/role/wildcard \
  secret_id_ttl=24h \
  token_num_uses=12 \
  token_ttl=12h \
  token_max_ttl=18h \
  secret_id_num_uses=1000 \
  policies=wildcard
Success! Data written to: auth/vaultron-approle/role/wildcard
```

Save role-id:

```
$ vault read -field=role_id auth/vaultron-approle/role/wildcard/role-id \
  > ./role_id.txt
```

Save secret-id:

```
$ vault write -f -field=secret_id auth/vaultron-approle/role/wildcard/secret-id \
  > ./secret_id.txt
```

Write Vault agent configuration:

```
$ cat << EOF > vault_agent.hcl
pid_file = "./pidfile"

vault {
        address = "https://127.0.0.1:8200"
        ca_path = "../../etc/tls"
}

auto_auth {
    method "approle" {
        mount_path = "auth/vaultron-approle"
        config = {
                role = "wildcard"
                role_id_file_path = "./role_id.txt"
                secret_id_file_path = "./secret_id.txt"
                remove_secret_id_file_after_reading = false
        }
    }

    sink "file" {
        config = {
                path = "./vaultron-agent-example"
        }
    }
}

cache {
        use_auto_auth_token = true
}

listener "tcp" {
         address = "127.0.0.1:8007"
         tls_disable = true
}
EOF
```

Vault agent with Transit Secrets Engine Example

Start the agent:

```
$ vault agent -config=vault_agent.hcl
```

In another terminal, use the agent address for `VAULT_ADDR` and use the contents of `vaultron-agent-example` as the value of `VAULT_TOKEN`; then create a Transit key for encryption and decryption.

Generate key:

```
$ VAULT_ADDR=http://127.0.0.1:8007 \
  VAULT_TOKEN=$(cat ./vaultron-agent-example) \
  vault write -f vaultron-transit/keys/my-key
Success! Data written to: vaultron-transit/keys/my-key
```

Encrypt:

```
$ VAULT_ADDR=http://127.0.0.1:8007 \
  VAULT_TOKEN=$(cat ./vaultron-agent-example) \
  vault write vaultron-transit/encrypt/my-key plaintext=$(base64 <<< "Vault agent is the shiznoz")
Key           Value
---           -----
ciphertext    vault:v1:bM6qMAJqCtjNzkyR6Zr202CvU2H6eyF2MZUBsJwZ7+N2CeCDV0rc/k07jBXutpxneb4mbp+kyw==
```

Decrypt:

```
$ VAULT_ADDR=http://127.0.0.1:8007 \
  VAULT_TOKEN=$(cat ./vaultron-agent-example) \
  vault write vaultron-transit/decrypt/my-key \
  ciphertext=vault:v1:bM6qMAJqCtjNzkyR6Zr202CvU2H6eyF2MZUBsJwZ7+N2CeCDV0rc/k07jBXutpxneb4mbp+kyw== -format=json | jq -r '.data.plaintext' \
  | base64 -D
Vault agent is the shiznoz
```

Ten decrypts:

```
for i in {1..10}; do echo $i && VAULT_ADDR=http://127.0.0.1:8007 VAULT_TOKEN=$(cat ./vaultron-agent-example) vault write vaultron-transit/decrypt/my-key ciphertext=vault:v1:EOgUCTGUQRgpVEOZE876YIK/o95wNKj+DEt+zbRe/+tF0ECVXNFQZH+5/2iG6tvWcPBO/TUWQQ== -format=json | jq -r '.data.plaintext' | base64 -D; done
1
Vault agent is the shiznoz
2
Vault agent is the shiznoz
3
Vault agent is the shiznoz
4
Vault agent is the shiznoz
5
Vault agent is the shiznoz
6
Vault agent is the shiznoz
7
Vault agent is the shiznoz
8
Vault agent is the shiznoz
9
Vault agent is the shiznoz
10
Error writing data to vaultron-transit/decrypt/my-key: Error making API request.

URL: PUT http://127.0.0.1:8007/v1/vaultron-transit/decrypt/my-key
Code: 403. Errors:

* permission denied
```

Vault agent logs:

```
==> Vault agent configuration:

           Api Address 1: http://127.0.0.1:8007
                     Cgo: disabled
               Log Level: info
                 Version: Vault v1.1.0
             Version Sha: 36aa8c8dd1936e10ebd7a4c1d412ae0e6f7900bd

2019-03-21T12:44:03.114-0400 [INFO]  sink.file: creating file sink
2019-03-21T12:44:03.115-0400 [INFO]  sink.file: file sink configured: path=./vaultron-agent-example
2019-03-21T12:44:03.117-0400 [INFO]  auth.handler: starting auth handler
2019-03-21T12:44:03.117-0400 [INFO]  auth.handler: authenticating
2019-03-21T12:44:03.117-0400 [INFO]  sink.server: starting sink server
2019-03-21T12:44:03.222-0400 [INFO]  auth.handler: authentication successful, sending token to sinks
2019-03-21T12:44:03.222-0400 [INFO]  auth.handler: starting renewal process
2019-03-21T12:44:03.222-0400 [INFO]  sink.file: token written: path=./vaultron-agent-example
2019-03-21T12:44:03.276-0400 [INFO]  auth.handler: renewed auth token
2019-03-21T12:45:03.036-0400 [INFO]  cache: received request: path=/v1/sys/mounts method=GET
2019-03-21T12:45:03.040-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/sys/mounts method=GET
2019-03-21T12:46:03.014-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/keys/my-key method=PUT
2019-03-21T12:46:03.015-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/keys/my-key method=PUT
2019-03-21T12:46:39.925-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/encrypt/my-key method=PUT
2019-03-21T12:46:39.926-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/encrypt/my-key method=PUT
2019-03-21T12:48:09.393-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:09.394-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:25.724-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:25.725-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:30.596-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:30.597-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:45.146-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:45.147-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:50.948-0400 [INFO]  cache: received request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
2019-03-21T12:48:50.949-0400 [INFO]  cache.apiproxy: forwarding request: path=/v1/vaultron-transit/decrypt/my-key method=PUT
```
