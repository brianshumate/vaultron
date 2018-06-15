#!/usr/bin/env python3

import os

import hvac

# Using plaintext
client = hvac.Client()
client = hvac.Client(url='https://localhost:8200', verify="/Users/brian/src/brianshumate/vaultron/etc/tls/ca-bundle.pem", token=os.environ['VAULT_TOKEN'])

client.write('secret/foo', baz='bar', lease='1h')

print(client.read('secret/foo'))

client.delete('secret/foo')


