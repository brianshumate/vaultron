# Terraform with Vault

This example contains the very Terraform configuration used to enable all of Vaultron's post-unseal example configuration items, including the following:

## Policies

- `vaultron_wildcard` grants all capabilities for `*`
- `vaultron_example_root_ns` and vaultron_example_namespace_ns example namespace management policies (requires [Vault Enterprise Namespaces](https://www.vaultproject.io/docs/enterprise/namespaces/index.html))
- `vaultron_example_token_admin` is an example token administrator policy


## File Based Audit Device

## Auth Methods

## Secrets Engines
