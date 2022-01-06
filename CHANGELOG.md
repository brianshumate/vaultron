## 3.8.4

- Vault 1.9.0, 1.9.1, and 1.9.2
- Consul 1.11.1
- Update documentation

## 3.8.3

- Vault 1.8.3
- Consul 1.10.3
- Update documentation

## 3.8.2

- Vault 1.8.2
- Consul 1.10.2
- Update documentation

## 3.8.1

- Vault 1.8.1

## 3.8.0

- Vault 1.8.0
- Consul 1.10.1
- Update documentation

## 3.7.5

- Vault v1.7.3
- Consul v1.9.7
- Update documentation

## 3.7.4

- Vault v1.7.2
- Update documentation

## 3.7.3

- Vault v1.7.1
- Update documentation

## 3.7.2

- Require Terraform >= 0.15.0
- Update documentation

## 3.7.1

- Update form script
- Update documentation example

## 3.7.0

- Vault v1.7.0
- Consul v1.9.4
- Update documentation

## 3.6.4

- Update Docker provider

## 3.6.3

- Vault v1.6.2
- Consul v1.9.2
- Update documentation

## 3.6.2

- Vault version 1.6.1

## 3.6.1

- Update for Terraform v0.14 compatibility
- Clean up .terraform.lock.hcl files in unform
- Script message improvements

## 3.6.0

- Vault v1.6.0
- Consul v1.9.0
- Switch to kreuzwerker/docker
- Update documentation

## 3.5.5

- Vault v1.5.4
- Consul v1.8.4
- Update documentation

## 3.5.4

- Vault 1.5.3
- Fix form script
- Remove deprecated use_vault_oss configuration
- Update documentation

## 3.5.3

- Upgrade for Terraform 0.13 compatibility
- Simplified required environment variable configuration for flavors & counts
- Add vault_disable_mlock configuration
  - Default is true for integrated storage (raft flavor)
  - Default is false for Consul storage (consul flavor)
- Update documentation

## 3.5.2

- Vault v1.5.2
- Consul v1.8.3
- Update scripts
- Update documentation

## 3.5.0

- Vault v1.5.0
- Consul v1.8.1
- Update scripts
- Update documentation

## 3.4.5

- Vault v1.4.3
- Katacoda awareness circuit

## 3.4.4

- Consul v1.8.0
- Configurable DOCKER_HOST TF variable
- Updates scripts
- Update documentation

## 3.4.3

- Consul v1.7.4
- Update documentation

## 3.4.2

- Vault v1.4.2
- Remove Consul DNS as container DNS source
- Update documentation

## 3.4.1

- Vault v1.4.1
- Update documentation

## 3.4.0

- Vault v1.4.0
- Introduce flavors
  - Reorganize locations for configuration and data
  - Consistent use of data volume for Raft and Filesystem storage backends
- Add Vault Integrated Storage (Raft) flavor
- Add Vault Consul Storage flavor
- Update documentation

## 3.3.0

- Vault v1.3.3
- Update scripts with more helpfulness in error outputs
- Update documentation

## 3.2.5

- Consul 1.7.0
- Fix Terraform issue with labels
- Update documentation

## 3.2.4

- Vault v1.3.2
- Consul v1.6.3
- Remove interpolation to prevent warnings (thanks @fprimex)
- Updated documentation

## 3.2.3

- Vault v1.3.1
- Update documentation

## 3.2.2

- Vault v1.3.0
- Consul v1.6.2
- Update documentation

## 3.2.1

- Vault v1.2.4
- Update Yellow Lion / telemetry / dashboard / etc.
- Update Black Lion custom template
- Update Agent guide
- Use 825d TTLs in server TLS material (Hi, Catalina!)
- Update documentation

## v3.2.0

- Vault v1.2.3
- Consul v1.6.1
- Revert to default system-wide TTL and Maximum TTL values
- Create private network in form/do not manage with TF
- Begin TLS configuration for Grafana and other container friends
- Update documentation

## v3.1.2

- Vault v1.2.2

## v3.1.1

- Vault v1.2.1
- Add `SYS_ADMIN` capability to all containers
- Update all templates filenames and template filename references
- Update documentation

## v3.1.0

- Vault v1.2.0
- Consul v1.5.3
- API_ADDR set in config template instead of environment variable
- Add vault_server_log_format and matching TF_VAR for choosing log format
- Update documentation

## v3.0.1

- Consul v1.5.2
- Add a Vaultron Docker private network to top level Terraform configuration
- Statically assign container IP addresses within vaultron-network
- Add SKIP_CHOWN to Vault container resources
- Update TLS certificates
- Update documentation

## v3.0.0

- BREAKING CHANGE: Vaultron now requires Terraform v0.12.0+ (thanks @fprimex)
- Update documentation

## v2.3.0

- Vault v1.1.3
- terraform fmt all the things!
- Set an explicit https VAULT_REDIRECT_ADDR in env
- Update documentation

## v2.2.4

- Consul v1.5.1
- Update documentation

## v2.2.3

- Add NET_ADMIN and SYS_PTRACE capabilities to all containers

## v2.2.2

- Vault v1.1.12
- Consul v1.5.0
- Reissued all certificates and keys
- Add RabbitMQ example
- Renamed CA cert file
- Update unform cleanup tasks
- Update documentation

## v2.2.1

- Vault v1.1.1
- Consul v1.4.4
- Update TLS certificates
- Update documentation

## v2.2.0

- Vault version 1.1.0
- Update scripts
- Update documentation

## v2.1.5

- Consul v1.4.3
- Disable client certs in custom template
- Update documentation

## v2.1.4

- Fixup scripts
- Update templates for Consul
- Use specific Node IDs in Consul so that ancient versions work again
- Update LDAP auth method examples

## v2.1.3

- Vault v1.0.3
- Consul v1.4.2
- Updated examples / documentation

## v2.1.2

- Vault v1.0.2
- Update documentation

## v2.1.1

- Vault v1.0.1
- Consul configuration cleanup and updates
- Update example / test scripts
- Add workaround to unform for uid 0 owned local Consul data under Linux
- Update documentation

## v2.1.0

- Vault v1.0.0
- Update Consul ACL token format
- Default log levels

## v2.0.3

- Vault v0.11.5
- Consul v1.4.0
- Remove enable_script_checks from older Consul templates
- blazing_sword now uses a separate Terraform configuration
- Update documentation

## v2.0.2

- Vault v0.11.4
- Container namespace
- Reloadable Vault log level
- Update scripts
- Update documentation

## v2.0.1

- Vault v0.11.3
- Consul v1.3.0
- Use `vaultN` for Consul client node names
- Update scripts
- Clean up configuration
- Update documentation

## v2.0.0

- Vault v0.11.2
- Yellow Lion is now more plug and play; see README for more details

## v1.9.1

- Vault v0.11.1
- Update configuration for telemetry
- Update documentation

## v1.9.0

- Vault v0.11.0
- Consul v1.2.2
- Additional DNS container configuration to leverage Consul DNS API
- Add tranistize test script
- Update apprulez test script
- Increase wait to 3 seconds in blazing_sword
- Add an acl_agent_master_token to Consul client & server agent configuration
- Update documentation

## v1.8.9

- Add Vault Agent example stubs
- Update documentation
- Update CONTRIBUTORS

## v1.8.8

- Update config path (thanks to feedback from @roooms)

## v1.8.7

- Vault version 0.10.4

## v1.8.6

- Consul v1.2.0

## v1.8.5

- Vault version 0.10.3
- Move to one unseal key in blazing_sword for simplicity
- Update published ports for standby instances
- Upate blazing_sword for published ports updates
- Move plugins folder to vault
- Fix test_vaultron
- Update Documentation

## v1.8.4

- Vault v0.10.1
- Consul v1.0.7
- Yellow Lion is now opt-in with TF_VAR_vaultron_telemetry_count=1
- Remove example Graphite service and health definitions
- Prefer simplicity over specificity in naming containers
- Remove beta and RC templates
- Correct typo in form script (thanks @greyspectrum)
- Correct typo in ion darts script (thanks @lauradiane)
- Change CHANGELOG sort ordering
- Update documentation

## v1.8.3

- Vault version 0.10.0
- Yellow Lion appears
- Clean up configuration cruft
- Health check and service definition examples for Yellow Lion container
- Update documentation

## v1.8.2

- Relax ACL default policy to allow while finalizing configuration
- Document TLS details

## v1.8.1

- Vault 0.10.0-beta1
- Complete TLS work

## v1.8.0

- Vault v0.9.6
- ACLs by default
- TLS by default
- Drop custom Consul version bits
- Script improvements

## v1.7.0

- Vault v0.9.5
- Consul v1.0.6
- Initial CLI capabilities checking added to skydome
- Examples/tests/scripts improvements
- Examples/tests/scripts updates
- Update documentation

## v1.6.5

- Vault v0.9.3
- Update blazing sword
- Adulted away from delightful emojis for the sake of a bit of UX portability
- Add a Root+Intermediate CA guide for PKI backend
- Update examples
- Update tests
- Update documentation

## v1.6.4

- Vault v0.9.1
- Added variable `vault_server_log_level` variable for Vault log level
- Updated templates
- Updated documentation


## v1.6.3

- Consul v1.0.2
- Monitoring with Graphite and Grafana guide
- PostgreSQL backend guide
- Updated example scripts

## v1.6.2

- Updated documentation
- Added more examples
- Renamed functions

## v1.6.1

- Consul 1.0.1
- Vault 0.9.0

## v1.6.0

- Consul 1.0.0
- Add initial file backend support
- Add initial Vault plugin support
- Custom TLS and TLS with file backend templates
- Update scripts
- Add more examples

## v1.5.5

- Vault version 0.8.3

## v1.5.4

- Update Consul to version 0.9.3
- Update Vault to version 0.8.2
- Explicitly opt out of Consul ACLs with acl_enforce_version_8 set to false in Consul versions >= 0.8.0

## v1.5.3

- Consul v0.9.2
- Implement `VAULT_CLUSTER_INTERFACE` from the default entrypoint script
- Explicitly set Raft protocol 3 in >= 0.8.x templates
- Improve form script
- Update documentation

## v1.5.2

- Update test_vaultron
- Reintroduce count on Consul clients (needs refinement)
- Correct Vault custom template configuration
- Terraform apply, init, and plan failures now show most recent output
- Fix test default var value
- Update documentation

## v1.5.1

- Fix for Consul server with count issue

## v1.5.0

- Vault version 0.8.0!
- Reduced resource usage via count pattern in Vault module (thanks @fprimex)
- Update indexes in naming for count usage
 - Fix unform script
- Even more blazing from Blazing Sword!
- TF count rebase (thanks @fprimex)
- Custom Vault binary support!

## v1.4.7

- Add support for Vault version 0.8.0-rc1
- Update and reflow on the README (shoutout to @angrycub for the inspiration!)
- Update example test scripts
- Address SC2181 in form
- Address SC2004 in unform
- Address SC2046 in skydome
- Preserve provider modules for Terraform 0.10.0+
- Add example for MongoDB secret backend

## v1.4.6

- Flip date and op in log names for easy reading (thanks @fprimex)
- Modularize Terraform configuration and more tests (thanks @fprimex)
- Consistent comment banners in configurations
- Remove TF logs on successful unform run
- Add some miscellaneous test scripts for Vault
- Fix a user message type
- Disable log cleanup (needs more discussion)
- Set `keep_locally` to true (addresses 2 TF errors during unform issue) \o/

## v1.4.5

- Add error tracking to unform (thanks @fprimex)
- POSIX changes that make dash happy (thanks @fprimex)
- Use terraform console to get config values (thanks @fprimex)
- Start a testing script (thanks @fprimex)
- Verified working in both Linux and Docker for Mac environments
- Log Terraform operations, store and use plan (thanks @fprimex)
- Move common things to Skydome, fixes to state handling (thanks @fprimex)
- Check for Terraform (fixes #6) and better Terraform output (thanks @fprimex)
- Set variables and ignore logs (thanks @fprimex)
- Update documentation

## v1.4.4

- Disable script checks in 0.9.0 configurations
- Spruce up scripts
- Add execute versus source checking to form script (thanks @fprimex)
- Drop to executing form instead of sourcing and prompt user to set env vars
- Add examples directory and initial Vault PKI policy example
- Add CONTRIBUTING.md
- Add CONTRIBUTORS.md

## v1.4.3

- Reduce range of acceptable Consul versions to those actually published
  to DockerHub (0.7.0-CURRENT)
- Remove templates for invalid Consul versions
- Update documentation

## v1.4.2

- Update OSS server common configuration template
- Move common configuration from entry point to templates

## v1.4.1

- Update form script
- Update Consul client configuration to match architectural diagram
- Improve form error output
- Switch from notion of "extra configuration" to "common configuration"
- Create server common configuration
- Add initial version-specific common configuration template stubs
- Have fun with "Technical Specifications" (remember the roots!)
- Add support for supported Vault docker image versions (0.6.1-CURRENT)
- Add support for supported Consul docker image versions (0.6.0-CURRENT)
- Update documentation

## v1.4.0

- Expose DNS from Consul server one to host Mac (tcp/udp 8600)
- Tidy up Terraform configuration
- Use consistent naming for Consul and Vault instances throughout
- Enable intial support for Consul and Vault version-specific configuration
- Use Consul servers for DNS
- Enable script checks
- Update documentation
- Update ignores

## v1.3.1

- HA mode confirmed working
- Update documentation

## v1.3.0

- Three Consul client agents
- Three Vault servers
- Provide audit logs directory mapping
- Enable file based audit logging on initially active server
- Update scripts
- Update documentation

## v1.2.0

- Cluster is now using Consul client agents to which Vault servers connect
- Stubbed a pre-0.7.x config file so that 0.6.x versions can be run soon
- Reworked naming to distinguish clients and servers
- Update documentation

## v1.1.1

- Keep with Voltron theme by renaming `vault_kitchen_sink` to `blazing_sword`
- Update documentation

## v1.1.0

- Removed Makefile and switched to direct script sourcing/executing
- Why so blue, vault_kitchen_sink?
- Updated README

## v1.0.2

- Add sad hack to disable registration since we have Vault talking to
  Consul server directly and health checks don't always work that way

## v1.0.1

- Configuration cleanup
- Variable translation fix for disable_clustering

## v1.0.0

- Initial release
 - One Vault server
 - Three Consul servers
