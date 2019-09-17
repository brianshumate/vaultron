## Visualizing Vault Telemetry

> **NOTE**: This can all be included in Vaultron by setting `TF_VAR_vaultron_telemetry_count=1`. Review the main README for more details on Vaultron's built in telemetry configuration

![](https://github.com/brianshumate/vaultron/blob/master/share/metrics.png?raw=true)

These are random insights and solutions for visualizing Vaultron telementry metrics with other container based solutions.

The simplest off-the-shelf solution is to use statsd, Graphite and Grafana.

- [Graphite + statsd container](https://github.com/graphite-project/docker-graphite-statsd)
- [Grafana container](https://hub.docker.com/r/grafana/grafana/)
  - [Installing using Docker](http://docs.grafana.org/installation/docker/)

NOTE: Vaultron now does all of this automatically with the Yellow Lion telemetry module. To enable it, export the following environment variable prior to executing `./form`:

```
export TF_VAR_vaultron_telemetry_count=1
```

You can then skip to **Initial Grafana Configuration** after Vaultron forms.

### Start Containers

First, start the Graphite + statsd container:

```
$ docker run \
  -d \
  --name vstatsd \
  --restart=always \
  -p 80:80 \
  -p 2003-2004:2003-2004 \
  -p 2023-2024:2023-2024 \
  -p 8125:8125/udp \
  -p 8126:8126 \
  graphiteapp/graphite-statsd
```

Then, get the IP address of the Graphite + statsd container:

```
$ docker inspect \
    --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    vstatsd
172.17.0.2
```

Now, set the environment variable `PATH_TO_VAULTRON_REPO` and make its value equal to the path where you cloned the Vaultron repo.

Then, start the Grafana container:

```
$ docker run \
  -d \
  --name vgrafana \
  -p 3000:3000 \
  -v $PATH_TO_VAULTRON_REPO/tmp/g-data:/var/lib/grafana \
  -e "GF_SECURITY_ADMIN_PASSWORD=vaultron" \
  -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" \
   grafana/grafana
```

Note that the *admin* user password is set to "vaultron" in the example, and some handy plugins are installed as well.

#### Initial Vaultron Configuration

Now, edit the custom configuration for Vaultron, located in `black_lion/templates/vault_config_custom.hcl`, and add a `telemetry` stanza containing the IP address and port for the Graphite container:

```
telemetry {
  statsd_address = "172.17.0.2:8125"
}
```

Use the address for the Graphite container and port `8125`.

Be sure to instruct Vaultron to use a custom configuration with:

```
$ export TF_VAR_vault_oss_instance_count=0 \
         TF_VAR_vault_custom_instance_count=3
```

and supply a `vault` binary in the `custom` path prior to running `./form`.

Once ready, go ahead and form Vaultron!

```
$ cd $VAULTRON_SRC_DIR
$ ./form
[=] Form Vaultron! ...
[=] Terraform has been successfully initialized!
[=] Vault Docker image version:    UNKNOWN (custom binary)
[=] Consul Docker image version:   1.0.3
[=] Terraform plan: 11 to add, 0 to change, 0 to destroy.
[=] Terraform apply complete! resources: 11 added, 0 changed, 0 destroyed.
[^] Vaultron formed!
```

#### Initial Grafana Configuration

Now we're ready for the initial Grafana configuration! This mostly involves adding our Graphite data source, and you can begin like this:

1. Vist http://127.0.0.1:3000/login
2. login as user `admin` with password `vaultron` (or custom password value)
3. Click **Add data source** and modify only the following:
  - Name: `Vaultron`
  - HTTP Settings:
    - URL: `http://172.17.0.2:80` (IP address from `docker inspect` above)
    - Access: **Server**
  - Graphite details
    - Version: **1.1.x**
4. Click **Add**

You should observe a dialog with "Data source is working" provided that the Grafana container can communicate with the graphite container.

Now it's on to defining a dashboard and panels!

#### Example Vault Ops Dashboard JSON

You are now ready to create dashboards to visualize Vault telemetry metrics!

There's an example in this folder named `vault-lab.json` that you can import into Grafana as a starting point.

1. Use the navigation menu from the top left Grafana icon
2. Navigate to **Dashboards**
3. **Import Dashboard** button
4. **Upload .json File** button
5. Navigate to and select the `vault-lab.son` from within this projects `examples/telemetry` folder
6. **Import** button

Now you'll need to edit some dashboard items (the ones with red/white exclamations and which have *No data points* in their graph displays) to choose appropriate Vault server (usually the active instance) by its Graphite data source ID in order to display their metrics in the graphs.

Or if it's not a server specific metric, typically editing the graph and selecting **Vaultron Graphite** as the data source re-enables the connection and the graph/counter will show live data again.

If the above does not help, make sure the engine, auth method, etc. is actually active on the Vault instances.

