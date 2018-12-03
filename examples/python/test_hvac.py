#!/usr/bin/env python3

import os
import hvac

client = hvac.Client(url='https://localhost:8200',
                     verify=os.environ['VAULT_CACERT'],
                     token=os.environ['VAULT_TOKEN'])

client.write('secret/foo',
              baz='bar',
              lease='1h')

print(client.read('secret/foo'))

client.delete('secret/foo')
