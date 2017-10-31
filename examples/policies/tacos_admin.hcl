# Allow reading/listing mounts for UI

path "sys/mounts" {
    capabilities = ["list", "read"]
}

# Allow sudo on taco secrets

path "secret/tacos/" {
    capabilities = ["list", "read", "create", "update", "delete", "sudo"]
}
