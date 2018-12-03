# Example "sudo" policy gives sudo to (most) all the things

path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "cubbyhole/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# For non root cert PKI things
path "pki/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

path "sys/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# A namespaced place to mount more things...
path "vaultron/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
