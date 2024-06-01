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
variable "refinputsetgittrigger" {}
variable "refgittrigger" {}
variable "refstepgrouptemplate" {}
variable "refsteptemplatepmd" {}
variable "refsteptemplategitleaks" {}
variable "refsteptemplatetrivy" {}
variable "refsteptemplategrype" {}

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
  })
}

resource "harness_platform_input_set" "inputsetgittrigger" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refinputsetgittrigger
  identifier    = var.refinputsetgittrigger
  pipeline_id   = harness_platform_pipeline.autopipeline.id
  yaml          = templatefile("inputsetforgittrigger.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    inputset_name = var.refinputsetgittrigger
    inputset_identifier = var.refinputsetgittrigger
    pipeline_identifier = harness_platform_pipeline.autopipeline.id
  })
}

resource "harness_platform_triggers" "gittrigger" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refgittrigger
  identifier    = var.refgittrigger
  target_id     = harness_platform_pipeline.autopipeline.id
  yaml          = templatefile("gittrigger.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    trigger_name = var.refgittrigger
    trigger_identifier = var.refgittrigger
    inputset_identifier = harness_platform_input_set.inputsetgittrigger.id
    pipeline_identifier = harness_platform_pipeline.autopipeline.id
  })
}

resource "harness_platform_template" "stepgrouptemplate" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refstepgrouptemplate
  identifier    = var.refstepgrouptemplate
  comments      = ""
  version       = "0.0.1"
  is_stable     = true
  template_yaml = templatefile("stepgrouptemplate.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_name = var.refstepgrouptemplate
    template_identifier = var.refstepgrouptemplate
  })
}

resource "harness_platform_template" "steptemplatepmd" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refsteptemplatepmd
  identifier    = var.refsteptemplatepmd
  comments      = ""
  version       = "0.0.1"
  is_stable     = true
  template_yaml = templatefile("steptemplatepmd.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_name = var.refsteptemplatepmd
    template_identifier = var.refsteptemplatepmd
  })
}

resource "harness_platform_template" "steptemplategitleaks" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refsteptemplategitleaks
  identifier    = var.refsteptemplategitleaks
  comments      = ""
  version       = "0.0.1"
  is_stable     = true
  template_yaml = templatefile("steptemplategitleaks.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_name = var.refsteptemplategitleaks
    template_identifier = var.refsteptemplategitleaks
  })
}

resource "harness_platform_template" "steptemplatetrivy" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refsteptemplatetrivy
  identifier    = var.refsteptemplatetrivy
  comments      = ""
  version       = "0.0.1"
  is_stable     = true
  template_yaml = templatefile("steptemplatetrivy.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_name = var.refsteptemplatetrivy
    template_identifier = var.refsteptemplatetrivy
  })
}

resource "harness_platform_template" "steptemplategrype" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refsteptemplategrype
  identifier    = var.refsteptemplategrype
  comments      = ""
  version       = "0.0.1"
  is_stable     = true
  template_yaml = templatefile("steptemplategrype.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    template_name = var.refsteptemplategrype
    template_identifier = var.refsteptemplategrype
  })
}

output "myoutput" {
  value       = {
    pipeline1 = harness_platform_pipeline.autopipeline.id
    inputset1 = harness_platform_input_set.inputset.id
    inputset2 = harness_platform_input_set.inputsetgittrigger.id
    trigger1  = harness_platform_triggers.gittrigger.id
    stepgrouptemplate = harness_platform_template.stepgrouptemplate.id
  }
}
