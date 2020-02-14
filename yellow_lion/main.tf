# =======================================================================
# Yellow Lion
# Vault telemetry stack
# statsd, graphite, Grafana
# =======================================================================

terraform {
  required_version = ">= 0.12"
}

# -----------------------------------------------------------------------
# Global variables
# -----------------------------------------------------------------------

variable "grafana_version" {
}

variable "statsd_ip" {
}

variable "statsd_version" {
}

variable "vaultron_telemetry_count" {
}

# -----------------------------------------------------------------------
# statsd / graphite image and container
# -----------------------------------------------------------------------

resource "docker_image" "statsd" {
  count        = var.vaultron_telemetry_count
  name         = "graphiteapp/graphite-statsd:${var.statsd_version}"
  keep_locally = true
}

resource "docker_container" "statsd_graphite" {
  count    = var.vaultron_telemetry_count
  name     = "vaultron-vstatsd"
  image    = docker_image.statsd[0].latest
  must_run = true
  restart  = "always"

  capabilities {
    add = ["NET_ADMIN", "SYS_PTRACE"]
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = "10.10.42.219"
  }

  ports {
    internal = "80"
    external = "80"
    protocol = "tcp"
  }

  ports {
    internal = "2003"
    external = "2003"
    protocol = "tcp"
  }

  ports {
    internal = "2004"
    external = "2004"
    protocol = "tcp"
  }

  ports {
    internal = "2023"
    external = "2023"
    protocol = "tcp"
  }

  ports {
    internal = "2024"
    external = "2024"
    protocol = "tcp"
  }

  ports {
    internal = "8125"
    external = "8125"
    protocol = "udp"
  }

  ports {
    internal = "8126"
    external = "8126"
    protocol = "tcp"
  }

}

# -----------------------------------------------------------------------
# Grafana image and container
# -----------------------------------------------------------------------

resource "docker_image" "grafana" {
  count        = var.vaultron_telemetry_count
  name         = "grafana/grafana:${var.grafana_version}"
  keep_locally = true
}

# Grafana configuration
data "template_file" "grafana_config" {
  count    = var.vaultron_telemetry_count
  template = file("${path.module}/templates/datasource.yml.hcl")

  vars = {
    statsd_ip = element(
      concat(docker_container.statsd_graphite.*.ip_address, [""]),
      0,
    )
  }
}

# -----------------------------------------------------------------------
# Grafana dashboard bootstrap configuration
# -----------------------------------------------------------------------

data "template_file" "grafana_dashboard_bootstrap_config" {
  count    = var.vaultron_telemetry_count
  template = file("${path.module}/templates/dashboard_bootstrap.yml.hcl")
}

# -----------------------------------------------------------------------
# Grafana dashboard configuration
# -----------------------------------------------------------------------

data "template_file" "grafana_dashboard_config" {
  count    = var.vaultron_telemetry_count
  template = file("${path.module}/templates/dashboard.json.hcl")
}

# -----------------------------------------------------------------------
# TLS configuration
# -----------------------------------------------------------------------

data "template_file" "int_ca_crt" {
  template = file("${path.module}/tls/vaultron-int-ca.crt")
}

data "template_file" "root_ca_crt" {
  template = file("${path.module}/tls/vaultron-root-ca.crt")
}

data "template_file" "grafana_tls_cert" {
  template = file("${path.module}/tls/grafana.crt")
}

data "template_file" "grafana_tls_key" {
  template = file("${path.module}/tls/grafana.key")
}

# -----------------------------------------------------------------------
# Grafana container
# -----------------------------------------------------------------------

resource "docker_container" "grafana" {
  count    = var.vaultron_telemetry_count
  name     = "vaultron-vgrafana"
  image    = docker_image.grafana[0].latest
  env      = ["GF_INSTANCE_NAME=Vaultron", "GF_DEFAULT_THEME=light", "GF_SECURITY_ADMIN_PASSWORD=vaultron", "GF_ALLOW_SIGN_UP=false", "GF_DISABLE_GRAVATAR=true", "GF_ALLOW_ORG_CREATE=false", "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource", "GF_SERVER_PROTOCOL=https", "GF_SERVER_CERT_FILE=/etc/ssl/certs/grafana.crt", "GF_SERVER_CERT_KEY=/etc/ssl/certs/grafana.key"]
  must_run = true

  capabilities {
    add = ["NET_ADMIN", "SYS_PTRACE"]
  }

  networks_advanced {
    name         = "vaultron-network"
    ipv4_address = "10.10.42.220"
  }

  volumes {
    host_path      = "${path.cwd}/yellow_lion/grafana_data"
    container_path = "/var/lib/grafana"
  }

  upload {
    content = element(data.template_file.int_ca_crt.*.rendered, count.index)
    file    = "/usr/local/share/ca-certificates/vaultron-int-ca.crt"
  }

  upload {
    content = element(data.template_file.root_ca_crt.*.rendered, count.index)
    file    = "/usr/local/share/ca-certificates/vaultron-root-ca.crt"
  }

  upload {
    content = element(data.template_file.grafana_tls_cert.*.rendered, count.index)
    file    = "/etc/ssl/certs/grafana.crt"
  }

  upload {
    content = element(data.template_file.grafana_tls_key.*.rendered, count.index)
    file    = "/etc/ssl/certs/grafana.key"
  }

  upload {
    content = element(data.template_file.grafana_config.*.rendered, count.index)
    file    = "/etc/grafana/provisioning/datasources/vaultron_datasource.yml"
  }

  upload {
    content = element(
      data.template_file.grafana_dashboard_bootstrap_config.*.rendered,
      count.index,
    )
    file = "/etc/grafana/provisioning/dashboards/vaultron_dashboard.yml"
  }

  upload {
    content = element(
      data.template_file.grafana_dashboard_config.*.rendered,
      count.index,
    )
    file = "/var/lib/grafana/provisioning/dashboards/vaultron_dashboard.json"
  }

  ports {
    internal = "3000"
    external = "3000"
    protocol = "tcp"
  }
}

