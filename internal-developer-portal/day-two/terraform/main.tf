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

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.pat
}

resource "harness_platform_pipeline" "guestbook_rolling_pipeline" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refpipeline
  identifier    = var.refpipeline
  yaml = templatefile("pipeline.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    pipeline_name       = var.refpipeline
    pipeline_identifier = var.refpipeline
  })
}


resource "harness_platform_environment" "harnessdevenv" {
  identifier    = "harnessdevenv"
  name          = "harnessdevenv"
  org_id        = var.org_id
  project_id    = var.project_id
  type          = "PreProduction"
}

resource "harness_platform_infrastructure" "harness_k8sinfra" {
  identifier      = "harness_k8sinfra"
  name            = "harness_k8sinfra"
  org_id          = var.org_id
  project_id      = var.project_id
  env_id          = harness_platform_environment.env_dev.id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = templatefile("infra-def.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    infra_name          = "harness_k8sinfra"
    infra_identifier    = "harness_k8sinfra"
    env_identifier      = harness_platform_environment.env_dev.id
    namespace           = "default"
  })
}

resource "harness_platform_service" "svc_guestbook" {
  identifier  = "guestbook"
  name        = "guestbook"
  description = "Guestbook web app"
  org_id      = var.org_id
  project_id  = var.project_id
  yaml        = templatefile("service.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    service_identifier  = "guestbook"
  })
}

output "pipeline_id" {
  value       = harness_platform_pipeline.guestbook_rolling_pipeline.id
}

output "environment_dev" {
  value       = harness_platform_environment.harnessdevenv.id
}

output "service_identifier" {
  value       = harness_platform_service.svc_guestbook.id
}