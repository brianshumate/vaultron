# Tiny Load Testing with Vaultron and Vegeta

This is tiny load testing/generation/blah for Vaultron with [Vegeta](https://github.com/tsenart/vegeta).

It's good for generating load to observe telemetry and other experimental/educational purposes, but not a valid benchmark or anything like that.

## Install Vegeta

Establish a Go environment and install Vegeta:

```
go get -u github.com/tsenart/vegeta
```

## Set s Test Token

Set an environment variable `TEST_TOKEN` to a token that can create the AppRole; it can be a root token or whatever since we're just playing here.

```
export TEST_TOKEN=
```

## Username and Password Auth Test

Vaultron enables a username and password auth method at `vaultron-userpass` and this example is based on it.

Create a user:

```
vault write auth/vaultron-userpass/users/vegeta \
  password=123456 \
  policies=wildcard
```

Create a payload:

```
tee vaultron_userpass_auth_payload.json - <<EOF
{
  "password": "123456"
}
EOF
```

Example attack:

```
echo "POST $VAULT_ADDR/v1/auth/vaultron-userpass/login/vegeta" \
  | vegeta attack \
  -insecure \
  -header="Content-Type: application/json" \
  -body=vaultron_userpass_auth_payload.json \
  -header="X-Vault-Token: $TEST_TOKEN" \
  -rate=50 \
  -duration=10s \
  | vegeta report \
  -type='hist[0,5ms,10ms,50ms,100ms,300ms,700ms]'
```

The results will look something like this:

```
Bucket           #    %       Histogram
[0s,     5ms]    297  59.40%  ############################################
[5ms,    10ms]   200  40.00%  ##############################
[10ms,   50ms]   3    0.60%
[50ms,   100ms]  0    0.00%
[100ms,  300ms]  0    0.00%
[300ms,  700ms]  0    0.00%
[700ms,  +Inf]   0    0.00%
```

## AppRole Test

Enable AppRole and define an example `my-role` role:

```
vault auth enable approle && \
vault write auth/approle/role/my-role \
  secret_id_ttl=120m \
  token_num_uses=500000 \
  token_ttl=60m \
  token_max_ttl=90m \
  secret_id_num_uses=250000
```

Successful output example:

```
Success! Enabled approle auth method at: approle/
Success! Data written to: auth/approle/role/my-role
```

Create a payload:

```
$ tee vaultron_approle_auth_payload.json <<EOF
{
  "role_id": "$(vault read -format=json auth/approle/role/my-role/role-id | jq -r '.data.role_id')",
  "secret_id": "$(vault write -format=json -f auth/approle/role/my-role/secret-id | jq -r '.data.secret_id')"
}
EOF
```

Successful output example:

```
{
  "role_id": "5dce838d-d0d1-3599-85a0-e0e3d2368b37",
  "secret_id": "89d899bc-d4dc-6879-a3e8-49e3470ab6dc"
}
```

Test:

```
$ echo "POST https://localhost:8200/v1/auth/approle/login" \
  | vegeta attack \
  -insecure \
  -header="Content-Type: application/json" \
  -body=vaultron_approle_auth_payload.json \
  -header="X-Vault-Token: $TEST_TOKEN" \
  -rate=20 \
  -duration=60s \
  | vegeta report \
  -type='hist[0,5ms,10ms,50ms,100ms,300ms,700ms]'
```

Variations:

```
$ echo "POST https://localhost:8200/v1/auth/approle/login" \
  | vegeta attack \
  -insecure \
  -header="Content-Type: application/json" \
  -body=vaultron_approle_auth_payload.json \
  -header="X-Vault-Token: $TEST_TOKEN" \
  -rate=120 \
  -duration=60s \
  | vegeta report \
  -type='hist[0,5ms,10ms,50ms,100ms,300ms,700ms,2s,10s]'
```

Count AppRole tokens:

```
$ consul kv get -recurse -separator="" -keys vault/logical/ | wc -l
```
