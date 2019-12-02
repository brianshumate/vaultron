# Postwoman

You can easily use the awesome project [Postwoman](https://github.com/liyasthomas/postwoman) as an API tool with Vaultron!

We build a custom image based on the `Dockerfile` in this project's directory to include the Vaultron CA certificate.

Build the image:

```
docker build -t postwoman-vaultron:latest .
```

When finished the output will contain:

```
Successfully built 8e80b7415702
Successfully tagged postwoman-vaultron:latest
```

Now you can run the image:

```
docker run \
  --detach \
  --rm \
  --ip 10.10.42.4 \
  --name vaultron-postwoman \
  --network vaultron-network \
  -p 3000:3000 \
  postwoman-vaultron:latest
```

Finally, before using Postwoman, configure Vault's CORS settings to specify the allowed origins so that Postwoman can query the Vault API.

```
vault write /sys/config/cors \
  allowed_origins="http://localhost:3000,http://10.10.42.4:3000"
```

The output should resemble:

```
Success! Data written to: sys/config/cors
```

Then, you can open the Postwoman UI at http://localhost:3000 and begin using it to communicate with Vaultron.

Here's a quick example demonstrating [/sys/health](https://www.vaultproject.io/api/system/health.html):

![](https://raw.githubusercontent.com/brianshumate/vaultron/master/share/postwoman-sys-health.png)
