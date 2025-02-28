#!/bin/bash

# Start Vault server
vault server -config=config.hcl &

# Wait for Vault to start
sleep 5

# Authenticate to Vault
vault login <your-sudo-token>

# Enable KV secrets engine
vault secrets enable -path=github-secrets kv

# Write a policy
vault policy write myapp-policy policies/myapp-policy.hcl

# Store secrets
vault kv put github-secrets/myapp/config username='myuser' password='mypassword'

# Create a token with the policy
vault token create -policy=myapp-policy
