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

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_policy" "mypolicy" {
  org_id        = var.org_id
  project_id    = var.project_id
  name        = "myrequiredstepspolicy"
  identifier  = "myrequiredstepspolicy"
  description = "myrequiredstepspolicy"
  rego        = <<-REGO
package pipeline

# Deny pipelines that are missing required steps
deny[msg] {
	# Find all stages ...
	stage = input.pipeline.stages[_].stage

	# ... that are deployments
	stage.type == "CI"

	# ... and create a list of all step types in use
	existing_steps := [s | s = stage.spec.execution.steps[_].step.name]

	# For each required step ...
	required_step := required_steps[_]

	# ... check if it's present in the existing steps
	not contains(existing_steps, required_step)

	# Show a human-friendly error message
	msg := sprintf("deployment stage '%s' is missing required step '%s'", [stage.name, required_step])
}

# Steps that must be present in every deployment
required_steps = ["docompilecode","dopublishpackage"]

contains(arr, elem) {
	arr[_] = elem
}
REGO
}

resource "harness_platform_policyset" "mypolicyset" {
  org_id        = var.org_id
  project_id    = var.project_id
  name        = "myrequiredstepspolicyset"
  identifier  = "myrequiredstepspolicyset"
  description = "myrequiredstepspolicyset"
  action     = "onrun"
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
