# Field limited / parameters example

path "secret/example" {
  capabilities = ["read"]
  allowed_parameters = {
    "public" = ["*"]
  }
  denied_parameters  {
    "private" = ["*"]
  }
}
