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

## v1.3.0

- Three Consul client agents
- Three Vault servers
- Provide audit logs directory mapping
- Enable file based audit logging on initially active server
- Update scripts
- Update documentation

## v1.3.1

- HA mode confirmed working
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

## v1.4.2

- Update OSS server common configuration template
- Move common configuration from entry point to templates

## v1.4.3

- Reduce range of acceptable Consul versions to those actually published
  to DockerHub (0.7.0-CURRENT)
- Remove templates for invalid Consul versions
- Update documentation

## v1.4.4

- Disable script checks in 0.9.0 configurations
- Spruce up scripts
- Add execute versus source checking to form script (thanks @fprimex)
- Drop to executing form instead of sourcing and prompt user to set env vars
- Add examples directory and initial Vault PKI policy example
- Add CONTRIBUTING.md
- Add CONTRIBUTORS.md

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

## v1.4.6

- Flip date and op in log names for easy reading (thanks @fprimex)
- Modularize Terraform configuration and more tests (thanks @fprimex)
- Consistent comment banners in configurations
- Remove TF logs on successful unform run
- Add some miscellaneous test scripts for Vault
- Fix a user message type
- Disable log cleanup (needs more discussion)
- Set `keep_locally` to true (addresses 2 TF errors during unform issue) \o/

## v1.4.7

- Add support for Vault version 0.8.0-rc1
- Update and reflow on the README (shoutout to @angrycub for the inspiration!)
- Update example test scripts
- Address SC2181 in form
- Address SC2004 in unform
- Address SC2046 in skydome
- Preserve provider modules for Terraform 0.10.0+
- Add example for MongoDB secret backend

## v1.5.0

- Vault version 0.8.0!
- Reduced resource usage via count pattern in Vault module (thanks @fprimex)
- Update indexes in naming for count usage
 - Fix unform script
- Even more blazing from Blazing Sword!
- TF count rebase (thanks @fprimex)
- Custom Vault binary support!

## v1.5.1

- Fix for Consul server with count issue

## v1.5.2 (UNRELEASED)

- Update test_vaultron
- Reintroduce count on Consul clients (needs refinement)
- Correct Vault custom template configuration
- Terraform apply, init, and plan failures now show most recent output
