# Vaultron HSM

This describes simple configuration of Vault Enterprise with SoftHSM in the context of Vaultron and Docker.

## Docker

The `Dockerfile` is not currently available from DockerHub, so it needs to be built before running:

Build:

```
$ docker build -t myhsm:latest .
```

Then run:

```
$ docker run myhsm:latest
```

## pkcs11-tool

If you need to troubleshoot / test with `pkcs11-tool1`, the OpenSC project provides a version of it that can be installed on macOS with:

```
$ brew install opensc
```
