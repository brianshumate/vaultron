VERSION:=$(shell cat version.txt)
BUILD_TIME:=$(shell date +%FT%T%z)
export CONSUL_HTTP_ADDR="localhost:8500"
export VAULT_ADDR="http://localhost:8200"

vaultron:
	@echo "✨  Make Vaultron ..."; \
	terraform plan > /dev/null 2>&1; \
	terraform apply > /dev/null 2>&1; \
    echo "✨  Set CONSUL_HTTP_ADDR to ${CONSUL_HTTP_ADDR}"; \
    echo "✨  Set VAULT_ADDR to ${VAULT_ADDR}"; \
	echo "🤖  Vaultron formed!"

all: vaultron

deploy: vaultron

install: vaultron

clean:
	@echo "🤖  Vaultron Disassemble ..."; \
	terraform destroy -force > /dev/null 2>&1; \
	rm -rf consul/oss_one/data/*; \
	rm -rf consul/oss_two/data/*; \
	rm -rf consul/oss_three/data/*; \
	rm -rf vault_*.tmp; \
	echo "💥  Vaultron Disassembled!"

.PHONY: vaultron
