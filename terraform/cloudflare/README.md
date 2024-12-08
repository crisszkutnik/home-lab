# Cloudflare Terraform configuration

Hello fellow reader! This is the Terraform configuration for my Cloudflare infrastructure. This is the infra that is used to expose my home cluster via Cloudflare tunnels but at the same time protect it with Cloudflare Access.

Unfortunately for you guys, there is a bunch of stuff here that was moved to variables in order to protect the configuration a little bit. You can take a look at the config but sensible data will be hidden.

## Instructions for me

I don't want to pay anyone to store my Terraform state file. I will be the only one modifying it so I will store it somewhere.

### Set up

1. Set `CLOUDFLARE_API_TOKEN`. Get the secret from 1Password
2. Get the `terraform.tfvars` file from 1Password
3. Get the state and paste it into the root directory
4. Run `terraform init`

After working on this please:

- Update `terraform.tfvars` in 1Password if updated
- Update Terraform state if updated
