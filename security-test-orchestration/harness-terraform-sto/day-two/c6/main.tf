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
variable "refpolicy" {}
variable "refpolicyset" {}
variable "reftemplate" {}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_policy" "mypolicy" {
  org_id        = var.org_id
  project_id    = var.project_id
  name        = var.refpolicy
  identifier  = var.refpolicy
  description = var.refpolicy
  rego        = <<-REGO
package pipeline

import future.keywords.in

# Security Test steps based on security tool that must be present in every Pipeline
required_templates = [${var.reftemplate}]

# Deny pipelines that are missing required steps
deny[msg] {
    # Find all stages ...
    stage = input.pipeline.stages[_].stage

    # ... that are Security and for Static Testing
    stage.type in ["SecurityTests"]
    stage.identifier in ["Static_Tests"]

    # ... and create a list of all templates types in use
    existing_templates := [s | s = stage.spec.execution.steps[_].parallel[_].stepGroup.template.templateRef]

    # For each required template ...
    required_template := required_templates[_]

    # ... check if it's present
    not contains(existing_templates, required_template)

    # Show a human-friendly error message
    msg := sprintf("stage '%s' is missing required template '%s'", [stage.name, required_template])
}

contains(arr, elem) {
    arr[_] = elem
}
REGO
}

resource "harness_platform_policyset" "mypolicyset" {
  org_id        = var.org_id
  project_id    = var.project_id
  name        = var.refpolicyset
  identifier  = var.refpolicyset
  description = var.refpolicyset
  action     = "onsave"
  type       = "pipeline"
  enabled    = true
  policies {
    identifier = harness_platform_policy.mypolicy.id
    severity   = "error"
  }
}

output "myoutput" {
  value       = {
    policy = harness_platform_policy.mypolicy.id
    policyset = harness_platform_policyset.mypolicyset.id
  }
}
