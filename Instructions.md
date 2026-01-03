# Instructions

## Setup Azure Backend (Storage Account)
    - https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli

## Azure Authentication

### Using service principal
* https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

Note: Required roles: Contributor, Role-Based Access Control Administrator (to add the acr)    

## Multi-Environment Deployment
```
    terraform workspace select dev
    terraform apply -var-file=./environment/dev.tfvars 
```

```
    terraform workspace select uat
    terraform apply -var-file=./environment/uat.tfvars
```

```
    terraform workspace select dev
    terraform apply -var-file=./environment/uat.tfvars
```