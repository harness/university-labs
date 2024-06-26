terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"
            version = "~> 0.30"
        }  
    }  
}

variable "sat" {}
variable "account_id" {}
variable "org_id" {}
variable "project_id" {}
variable "agent_name" {}
variable "agent_namespace" {}
variable "repo_name" {}
variable "repo_url" {}
variable "repo_username" {}
variable "repo_password" {}
variable "cluster_name" {}
variable "application_name" {}
variable "application_namespace" {}
variable "repo_deployment_revision" {}
variable "repo_deployment_folderpath" {}
variable "repo_deployment_valuesfilepath" {}
variable "repo_deployment_valuesoverride" {}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.sat
}

resource "harness_platform_gitops_applications" "gitops_application" {
  project_id = var.project_id
  org_id     = var.org_id
  account_id = var.account_id
  identifier = var.application_name
  cluster_id = var.cluster_name
  repo_id    = var.repo_name
  agent_id   = var.agent_name
  name       = var.application_name

  application {
    metadata {
      annotations = {}
      labels = {}
      name = var.application_name
    }
    spec {
      sync_policy {
        automated {
          allow_empty = true
          self_heal = true
          prune = true
        }
        sync_options = [
          "PrunePropagationPolicy=undefined",
          "CreateNamespace=true",
          "Validate=false",
          "skipSchemaValidations=false",
          "autoCreateNamespace=false",
          "pruneLast=false",
          "applyOutofSyncOnly=false",
          "Replace=false",
          "retry=true"
        ]
      }
      source {
        repo_url        = var.repo_url
        target_revision = var.repo_deployment_revision
        path            = var.repo_deployment_folderpath
        helm {
            value_files = [
                var.repo_deployment_valuesfilepath
            ]
            values      = var.repo_deployment_valuesoverride
        }
      }
      destination {
        namespace = var.application_namespace
        server    = "https://kubernetes.default.svc"
      }
    }
  }
}
