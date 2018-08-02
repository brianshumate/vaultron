# Vault Agent

Some examples for using Vault Agent with Vaultron


## Configuration Example


```
pid_file = "./pidfile"

auto_auth {
        method "jwt" {
                path = "./example.jwt"
                config = {
                        role = "sudo"
                }
        }

        sink "file" {
                config = {
                        path = "/tmp/vaultron-agent-example"
                }
        }

        sink "file" {
                wrap_ttl = "5m"
                aad_env_var = "TEST_AAD_ENV"
                dh_type = "curve25519"
                dh_path = "/tmp/file-foo-dhpath2"
                config = {
                        path = "/tmp/file-bar"
                }
        }
}
```
