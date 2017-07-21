## v1.0.0

- Initial release
 - One Vault server
 - Three Consul servers

## v1.0.1

- Configuration cleanup
- Variable translation fix for disable_clustering

## v1.0.2

- Add sad hack to disable registration since we have Vault talking to
  Consul server directly and health checks don't always work that way

## v1.1.0

- Removed Makefile and switched to direct script sourcing/executing
- Why so blue, vault_kitchen_sink?
- Updated README

## v1.1.1

- Keep with Voltron theme by renaming `vault_kitchen_sink` to `blazing_sword`
- Update documentation

## v1.2.0

- Cluster is now using Consul client agents to which Vault servers connect
- Stubbed a pre-0.7.x config file so that 0.6.x versions can be run soon
- Reworked naming to distinguish clients and servers
- Update documentation
