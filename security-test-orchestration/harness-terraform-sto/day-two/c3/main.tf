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
variable "refpipeline1" {}
variable "refpipeline2" {}
variable "container_registry_link" {}
variable "refinputset" {}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_pipeline" "autopipeline1" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refpipeline1
  identifier    = var.refpipeline1
  git_details {
    branch_name    = "main"
    commit_message = "Create ${var.refpipeline1} in my-harness-configs-${var.project_id}"
    file_path      = ".harness/${var.refpipeline1}.yaml"
    store_type     = "REMOTE"
    repo_name      = "my-harness-configs-${var.project_id}"
  }
  yaml = templatefile("pipeline1.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    pipeline_identifier = var.refpipeline1
    container_registry_link = var.container_registry_link
  })
}

resource "harness_platform_pipeline" "autopipeline2" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refpipeline2
  identifier    = var.refpipeline2
  git_details {
    branch_name    = "main"
    commit_message = "Create ${var.refpipeline2} in my-harness-configs-${var.project_id}"
    file_path      = ".harness/${var.refpipeline2}.yaml"
    store_type     = "REMOTE"
    repo_name      = "my-harness-configs-${var.project_id}"
  }  
  yaml = templatefile("pipeline2.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    pipeline_identifier = var.refpipeline2
    container_registry_link = var.container_registry_link
  })
}

resource "harness_platform_input_set" "inputset" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refinputset
  identifier    = var.refinputset
  pipeline_id   = harness_platform_pipeline.autopipeline2.id
  git_details {
    branch_name    = "main"
    commit_message = "Create ${var.refinputset} in my-harness-configs-${var.project_id}"
    file_path      = ".harness/${var.refinputset}.yaml"
    store_type     = "REMOTE"
    repo_name      = "my-harness-configs-${var.project_id}"
  }
  yaml          = templatefile("inputset.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    inputset_name = var.refinputset
    inputset_identifier = var.refinputset
    pipeline_identifier = harness_platform_pipeline.autopipeline2.id
    container_registry_link = var.container_registry_link
  })
}

output "myoutput" {
  value       = {
    pipeline1 = harness_platform_pipeline.autopipeline1.id
    pipeline2 = harness_platform_pipeline.autopipeline2.id
    inputset = harness_platform_input_set.inputset.id
  }
}
