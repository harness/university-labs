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
variable "refinputset" {}
variable "refstepgrouptemplate" {}

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
    pipeline_name = var.refpipeline
    pipeline_identifier = var.refpipeline
    template_identifier = var.refstepgrouptemplate
  })
  depends_on = [harness_platform_template.stepgrouptemplate]
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
  })
}

resource "harness_platform_template" "stepgrouptemplate" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refstepgrouptemplate
  identifier    = var.refstepgrouptemplate
  comments      = ""
  version       = "1.0.0"
  is_stable     = true
  template_yaml = templatefile("stepgrouptemplate.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_identifier = var.refstepgrouptemplate
  })
}

output "myoutput" {
  value       = {
    pipeline1 = harness_platform_pipeline.autopipeline.id
    inputset = harness_platform_input_set.inputset.id
    stepgrouptemplate = harness_platform_template.stepgrouptemplate.id
  }
}
