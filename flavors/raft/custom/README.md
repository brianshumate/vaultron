# custom

Place your custom `vault` binaries here and set the following environment variables to use them:

- `TF_VAR_vault_oss_instance_count=0`
- `TF_VAR_vault_custom_instance_count=3`

For example:

```
export TF_VAR_vault_oss_instance_count=0 \
       TF_VAR_vault_custom_instance_count=3
```
