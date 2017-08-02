#!/usr/bin/env bash

# Create N generic secrets in Vault

program="$(basename "$0")"

if [ $# -eq 0 ]
  then
    echo "Usage: ${program} <number_of_secrets>"
    exit 1
fi

while [[ $i -le $1 ]]

do
    sec_item="secret/bar${i} id=$(uuidgen)"
    vault write ${sec_item}
    #echo "${sec_item}"
    ((i = i + 1))
done
