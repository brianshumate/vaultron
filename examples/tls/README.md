# TLS Notes

You can generate an initial root cert and key with numerous SANs applicable to Vaultron and place them where they should be located prior to startup with these commands:

```
./init_pki
cp vault.crt ../../custom/
cp vault.key ../../custom/
```

With a key and certificate present, you can then enable Vault with a file based backend to avoid the need for TLS enabled Consul agents by setting these environment variables prior to forming Vaultron:

```
export TF_VAR_vault_oss_instance_count=0 TF_VAR_vault_custom_instance_count=3
export TF_VAR_vault_custom_config_template="vault_config_custom_tls_file.tpl"
```
