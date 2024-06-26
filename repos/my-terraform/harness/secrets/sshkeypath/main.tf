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

resource "harness_platform_secret_sshkey" "sshkeypath" {
  org_id      = var.mysshkeypathorgid
  project_id  = var.mysshkeypathprojectid
  identifier  = var.mysshkeypathidentifier
  name        = var.mysshkeypathname
  description = var.mysshkeypathdescription
  port        = 22
  ssh {
    sshkey_path_credential {
      user_name            = var.mysshkeypathusername
      key_path             = var.mysshkeypathkeypath
    }
    credential_type = "KeyPath"
  }
}
