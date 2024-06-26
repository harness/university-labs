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

resource "harness_platform_connector_git" "connector" {
  org_id      = var.mygitconnectororgid
  project_id  = var.mygitconnectorprojectid
  identifier  = var.mygitconnectoridentifier
  name        = var.mygitconnectorname
  description = var.mygitconnectordescription
  
  url                = var.mygitconnectorurl
  connection_type    = var.mygitconnectorconnectiontype
  credentials {
    http {
      username     = var.mygitconnectorusername
      password_ref = var.mygitconnectorpassword
    }
  }
  delegate_selectors = [var.mygitconnectordelegateselector]
}
