# Allow reading/listing mounts for UI

path "sys/mounts" {
    capabilities = ["list", "read"]
}

# Allow reading surfboards

path "secret/surfboards/*" {
    capabilities = ["list", "read", "create", "update"]
}
