#!/usr/bin/env bash

# Create various K/V entries in Consul

create_foo() {
    for i in {1..100}; do
        curl \
        --request PUT \
        --data 'hello=🌍' \
        "${CONSUL_HTTP_ADDR}/v1/kv/foo/foo-key-${i}";
    done
}

create_bar() {
    for i in {1..100}; do
        curl \
        --request PUT \
        --data 'hello=🌍' \
        "${CONSUL_HTTP_ADDR}/v1/kv/bar/bar-key-${i}";
    done
}

create_baz() {
    for i in {1..100}; do
        curl \
        --request PUT \
        --data 'hello=🌍' \
        "${CONSUL_HTTP_ADDR}/v1/kv/baz/baz-key-${i}";
    done
}

create_qux() {
    for i in {1..100}; do
        curl \
        --request PUT \
        --data 'hello=🌍' \
        "${CONSUL_HTTP_ADDR}/v1/kv/qux/qux-key-${i}";
    done
}

create_foo
create_bar
create_baz
create_qux
