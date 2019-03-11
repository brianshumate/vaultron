# Tiny Load Testing with Vaultron and Vegeta

This is tiny load testing/generation/blah for Vaultron with [Vegeta](https://github.com/tsenart/vegeta).

It's good for generating load to observe telemetry and other experimental/educational purposes, but not a valid benchmark or anything like that.

## Install Vegeta

Establish a Go environment and install Vegeta:

```
$ go get -u github.com/tsenart/vegeta
```

## Username and Password Auth Test

Vaultron enables a username and password auth method at `vaultron-userpass` and this example is based on it.

Create a user:

```
$ vault write auth/vaultron-userpass/users/vegeta \
  password=123456 \
  policies=wildcard
```

Create a payload:

```
$ tee vaultron_userpass_auth_payload.json - <<EOF
{
  "password": "123456"
}
EOF
```

```
echo "POST https://localhost:8200/v1/auth/vaultron-userpass/login/vegeta" \
  | vegeta attack \
  -insecure \
  -header="Content-Type: application/json" \
  -body=vaultron_userpass_auth_payload.json \
  -header="X-Vault-Token: $VAULT_ROOT_TOKEN" \
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

