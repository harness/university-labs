terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"
            version = "~> 0.30"
        }  
    }  
    
    backend "local" {
    }
}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.my_harness_account_id
    platform_api_key    = var.my_harness_peronal_access_token 
}