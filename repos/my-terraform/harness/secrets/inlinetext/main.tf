terraform {
    required_providers {  
        harness = {  
            source = "harness/harness"
            version = "~> 0.30"
        }  
    } 
}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.myharnessaccountid
    platform_api_key    = var.myharnessserviceaccesstoken 
}

resource "harness_platform_secret_text" "secrettextinline" {
  org_id      = var.mysecrettextinlineorgid
  project_id  = var.mysecrettextinlineprojectid
  identifier  = var.mysecrettextinlineidentifier
  name        = var.mysecrettextinlinename
  description = var.mysecrettextinlinedescription
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = var.mysecrettextinlinevalue
}
