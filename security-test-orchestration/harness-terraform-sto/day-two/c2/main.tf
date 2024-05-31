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
variable "refpipeline" {}
variable "container_registry_link" {}
variable "refinputset" {}
variable "refcosignsecret" {}
variable "cosignpubkey" {}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_pipeline" "autopipeline" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refpipeline
  identifier    = var.refpipeline
  yaml = templatefile("pipeline.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    pipeline_identifier = var.refpipeline
    container_registry_link = var.container_registry_link
  })
}

resource "harness_platform_input_set" "inputset" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refinputset
  identifier    = var.refinputset
  pipeline_id   = harness_platform_pipeline.autopipeline.id
  yaml          = templatefile("inputset.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    inputset_name = var.refinputset
    inputset_identifier = var.refinputset
    pipeline_identifier = harness_platform_pipeline.autopipeline.id
    container_registry_link = var.container_registry_link
  })
}

resource "harness_platform_secret_text" "harnesscosignsecret" {
  identifier  = var.refcosignsecret
  name        = var.refcosignsecret
  org_id      = var.org_id
  project_id  = var.project_id
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = var.cosignpubkey
}

output "myoutput" {
  value       = {
    pipeline = harness_platform_pipeline.autopipeline.id
    inputset = harness_platform_input_set.inputset.id
    secret = harness_platform_secret_text.harnesscosignsecret.id
  }
}
