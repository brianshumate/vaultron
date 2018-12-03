// Vaultron example policy: "wildcard"
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
