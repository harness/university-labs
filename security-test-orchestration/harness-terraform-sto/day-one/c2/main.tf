terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"
            version = "~> 0.30"
        }  
    }  
}

variable "account_id" {}
variable "org_id" {}
variable "project_id" {}
variable "pat" {}
variable "cosignpubkey" {}
variable "refpatsecret" {}
variable "refcosignsecret" {}


provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_secret_text" "harnesspatsecret" {
  identifier  = var.refpatsecret
  name        = var.refpatsecret
  org_id      = var.org_id
  project_id  = var.project_id
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = var.pat
}

resource "harness_platform_secret_text" "harnesscosignsecret" {
  identifier  = var.refcosignsecret
  name        = var.refcosignsecret
  org_id      = var.org_id
  project_id  = var.project_id
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = var.cosignpublickey
}


output "myharnesspatsecretoutput" {
  value       = harness_platform_secret_text.harnesspatsecret.id
}

output "myharnesscosignsecretoutput" {
  value       = harness_platform_secret_text.harnesscosignsecret.id
}
