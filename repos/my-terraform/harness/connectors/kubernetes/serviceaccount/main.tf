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

resource "harness_platform_connector_kubernetes" "serviceaccount" {
  org_id      = var.myk8ssaorgid
  project_id  = var.myk8ssaprojectid
  identifier  = var.myk8ssaidentifier
  name        = var.myk8ssaname
  description = var.myk8ssadescription

  service_account {
    master_url                = var.myk8ssamasterurl
    service_account_token_ref = var.myk8ssatoken
  }
  delegate_selectors = [var.myk8ssadelegateselector]
}
