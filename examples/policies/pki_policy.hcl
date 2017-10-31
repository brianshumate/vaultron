# PKI policies: allow non-root token to do work with the PKI backend

# Generate root certificate
path "pki/root/generate/internal" {
  capabilities = ["update"]
}

# URL configuration
path "pki/config/urls" {
  capabilities = ["update"]
}

# Role configuration
path "pki/roles/*" {
  capabilities = ["update"]
}

# Issue certificates
path "pki/issue/*" {
  capabilities = ["update"]
}
