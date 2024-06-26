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
variable "cluster_name" {}
variable "refservice" {}
variable "refservicerepo" {}
variable "refenvironment" {}
variable "refenvtype" {}
variable "refpipeline" {}
variable "refcontainerimage" {}
variable "refgittrigger" {}
variable "refvaluesfile" {}

provider "harness" {
    endpoint            = "https://app.harness.io/gateway"
    account_id          = var.account_id
    platform_api_key    = var.sat
}

resource "harness_platform_service" "service" {
  org_id      = var.org_id
  project_id  = var.project_id 
  identifier  = var.refservice
  name        = var.refservice
  yaml = templatefile("service.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    service_name = var.refservice
    service_identifier = var.refservice
    service_manifestreponame = var.refservicerepo
  })
}

resource "harness_platform_environment" "environment" {
  org_id     = var.org_id
  project_id = var.project_id
  identifier = var.refenvironment
  name       = var.refenvironment
  type       = var.refenvtype
  yaml = templatefile("environment.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    environment_name = var.refenvironment
    environment_identifier = var.refenvironment
    env_type = var.refenvtype
  })
}

resource "harness_platform_environment_clusters_mapping" "envclustermap" {
  identifier = "mycustomidentifier"
  org_id     = var.org_id
  project_id = var.project_id
  env_id     = harness_platform_environment.environment.id
  clusters {
    identifier       = var.cluster_name
    name             = var.cluster_name
    agent_identifier = "project.${var.agent_name}"
    scope            = "PROJECT"
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
