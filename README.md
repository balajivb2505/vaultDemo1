# GitHub + Vault Integration Example

This repository demonstrates how to integrate HashiCorp Vault with GitHub to manage secrets and access them in a GitHub Actions workflow.

## Prerequisites

- HashiCorp Vault installed and running.
- GitHub account and repository.
- Administrative privileges on Vault.

## Setup Vault

1. **Start Vault Server**

   Ensure your Vault server is running and accessible. If not, start it using the appropriate command:

   ```bash
   vault server -config=config.hcl
   ```

2. **Authenticate to Vault**

   Authenticate to Vault with a token that has sufficient permissions to mount secret engines:

   ```bash
   vault login <your-sudo-token>
   ```

   Replace `<your-sudo-token>` with your Vault token that has `sudo` capabilities.

3. **Enable the KV (Key-Value) Secrets Engine**

   Mount the KV secrets engine at the desired path (e.g., `github-secrets`):

   ```bash
   vault secrets enable -path=github-secrets kv
   ```

4. **Store Secrets in Vault**

   Store a secret in Vault:

   ```bash
   vault kv put github-secrets/myapp/config username='myuser' password='mypassword'
   ```

## Setup GitHub Actions

1. **Create GitHub Actions Workflow**

   Create a GitHub Actions workflow file in your repository. For example, `.github/workflows/deploy.yml`:

   ````yaml name=.github/workflows/deploy.yml
   name: Deploy

   on: [push]

   jobs:
     deploy:
       runs-on: ubuntu-latest

       steps:
       - name: Checkout code
         uses: actions/checkout@v2

       - name: Install Vault
         run: |
           curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
           sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
           sudo apt-get update && sudo apt-get install vault

       - name: Authenticate to Vault
         env:
           VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
           GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
         run: |
           vault login -method=github token=${GITHUB_TOKEN}

       - name: Retrieve secrets
         run: |
           vault kv get -format=json github-secrets/myapp/config | jq -r .data.data.username
           vault kv get -format=json github-secrets/myapp/config | jq -r .data.data.password
