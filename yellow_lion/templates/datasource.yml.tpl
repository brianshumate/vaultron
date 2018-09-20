# config file version
apiVersion: 1

deleteDatasources:
  - name: Vaultron
    orgId: 1
datasources:
- name: Vaultron
  type: graphite
  access: proxy
  orgId: 1
  url: http://${statsd_ip}
  password:
  user:
  database:
  basicAuth:
  basicAuthUser:
  basicAuthPassword:
  withCredentials:
  isDefault:
  jsonData:
     graphiteVersion: "1.1"
     tlsAuth: false
     tlsAuthWithCACert: false
  secureJsonData:
    tlsCACert: ""
    tlsClientCert: ""
    tlsClientKey: ""
  version: 1
  editable: true