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

resource "harness_platform_pipeline" "cd_pipeline" {
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


resource "harness_platform_environment" "env_dev" {
  identifier    = "dev"
  name          = "dev"
  org_id        = var.org_id
  project_id    = var.project_id
  type          = "PreProduction"
}

resource "harness_platform_infrastructure" "infra_dev" {
  identifier      = "dev_infra"
  name            = "dev_infra"
  org_id          = var.org_id
  project_id      = var.project_id
  env_id          = harness_platform_environment.env_dev.id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = templatefile("infra-def.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    infra_name          = "dev_infra"
    infra_identifier    = "dev_infra"
    env_identifier      = harness_platform_environment.env_dev.id
    namespace           = "dev"
  })
}

resource "harness_platform_environment" "env_qa" {
  identifier    = "qa"
  name          = "qa"
  org_id        = var.org_id
  project_id    = var.project_id
  type          = "PreProduction"
}

resource "harness_platform_infrastructure" "infra_qa" {
  identifier      = "qa_infra"
  name            = "qa_infra"
  org_id          = var.org_id
  project_id      = var.project_id
  env_id          = harness_platform_environment.env_qa.id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = templatefile("infra-def.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    infra_name          = "qa_infra"
    infra_identifier    = "qa_infra"
    env_identifier      = harness_platform_environment.env_qa.id
    namespace           = "qa"
  })
}

resource "harness_platform_environment" "env_prod" {
  identifier    = "prod"
  name          =  "prod"
  org_id        = var.org_id
  project_id    = var.project_id
  type          = "Production"
}

resource "harness_platform_infrastructure" "infra_prod" {
  identifier      = "prod_infra"
  name            = "prod_infra"
  org_id          = var.org_id
  project_id      = var.project_id
  env_id          = harness_platform_environment.env_prod.id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = templatefile("infra-def.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    infra_name          = "prod_infra"
    infra_identifier    = "prod_infra"
    env_identifier      = harness_platform_environment.env_prod.id
    namespace           = "prod"
  })
}

resource "harness_platform_service" "svc_nginx" {
  identifier  = "nginx"
  name        = "nginx"
  description = "Basic web server running nginx"
  org_id      = var.org_id
  project_id  = var.project_id
  yaml        = templatefile("service.yaml", {
    org_identifier      = var.org_id
    project_identifier  = var.project_id
    service_identifier  = "nginx"
  })
}

output "pipeline_id" {
  value       = harness_platform_pipeline.cd_pipeline.id
}

output "environment_dev" {
  value       = harness_platform_environment.env_dev.id
}

output "environment_qa" {
  value       = harness_platform_environment.env_qa.id
}

output "environment_prod" {
  value       = harness_platform_environment.env_prod.id
}

output "service_identifier" {
  value       = harness_platform_service.svc_nginx.id
}