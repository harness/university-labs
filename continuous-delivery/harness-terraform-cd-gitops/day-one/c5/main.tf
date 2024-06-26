terraform {  
    required_providers {  
        harness = {  
            source = "harness/harness"
            version = "~> 0.30"
        }  
    }  
}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.sat
}

variable "sat" {}
variable "account_id" {}
variable "org_id" {}
variable "project_id" {}
variable "agent_name" {}
variable "cluster_name" {}
variable "refservice" {}
variable "refservicerepo" {}
variable "refenvironment" {}
variable "refenvtype" {}
variable "refpipeline" {}
variable "refcontainerimage" {}
variable "refgittrigger" {}
variable "refvaluesfile" {}
variable "agent_name" {}
variable "agent_namespace" {}

resource "harness_platform_gitops_agent" "gitops_agent" {
  identifier = var.agent_name
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  name       = var.agent_name
  type       = "MANAGED_ARGO_PROVIDER"
  operator   = "ARGO"
  metadata {
    namespace         = var.agent_namespace
    high_availability = false
  }
}

resource "harness_platform_pipeline" "pipeline" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refpipeline
  identifier    = var.refpipeline
  yaml = templatefile("pipeline.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    pipeline_name = var.refpipeline
    pipeline_identifier = var.refpipeline
    container_image = var.refcontainerimage
    service_identifier = harness_platform_service.service.id
    environment_identifier = harness_platform_environment.environment.id
    codebase_name = var.refservicerepo
    cluster_name = var.cluster_name
    agent_name = var.agent_name
  })
}

resource "harness_platform_triggers" "gittrigger" {
  org_id        = var.org_id
  project_id    = var.project_id
  name          = var.refgittrigger
  identifier    = var.refgittrigger
  target_id     = var.refpipeline
  yaml          = templatefile("gittrigger.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    trigger_name = var.refgittrigger
    trigger_identifier = var.refgittrigger
    pipeline_identifier = harness_platform_pipeline.pipeline.id
    codebase_name = var.refservicerepo
    values_file = var.refvaluesfile
    service_identifier = harness_platform_service.service.id
  })
}
