# Example operator commands

## Migrate

Using the example `migrate.hcl` included in this project, you can migrate Vaultron data from Consul to a file system representation that can be used with the file system storage backend.

Vault should not be operational when `vault operator migrate` is used. You can stop the Vault server containers like this:

```
$ for i in {0..2}; do docker stop vaultron-vault$i; done
vaultron-vault0
vaultron-vault1
vaultron-vault2
```

Execute this from the root of the Vaultron project:

```
$ vault operator migrate -config examples/operator/migrate.hcl
```

It should return a success message like this:

```
Success! All of the keys have been migrated.
```
