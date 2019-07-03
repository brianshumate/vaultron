# Allow misc lookup and creation of orphan tokens

# Lookup, create, and revoke tokens
path "auth/token*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Create orphan tokens
path "auth/token/create/approle_om_access" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
