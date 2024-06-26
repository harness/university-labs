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
variable "prod_agent_name" {}
variable "dev_agent_name" {}
variable "prod_application_name" {}
variable "dev_application_name" {}
variable "prod_cluster_name" {}
variable "dev_cluster_name" {}
variable "refservice" {}
variable "refservicerepo" {}
variable "refprodenvironment" {}
variable "refdevenvironment" {}
variable "refpipeline" {}
variable "refcontainerimage" {}
variable "refgittrigger" {}
variable "refprodvaluesfile" {}
variable "refdevvaluesfile" {}

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
  force_delete = true
  yaml = templatefile("service.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    service_name = var.refservice
    service_identifier = var.refservice
    service_manifestreponame = var.refservicerepo
  })
}

resource "harness_platform_environment" "prod_environment" {
  org_id     = var.org_id
  project_id = var.project_id
  identifier = var.refprodenvironment
  name       = var.refprodenvironment
  type       = "Production"
  force_delete = true
  yaml = templatefile("environment.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    environment_name = var.refprodenvironment
    environment_identifier = var.refprodenvironment
    env_type = "Production"
  })
}

resource "harness_platform_environment" "dev_environment" {
  org_id     = var.org_id
  project_id = var.project_id
  identifier = var.refdevenvironment
  name       = var.refdevenvironment
  type       = "PreProduction"
  force_delete = true
  yaml = templatefile("environment.yaml", {
    org_identifier = var.org_id
    project_identifier = var.project_id
    environment_name = var.refdevenvironment
    environment_identifier = var.refdevenvironment
    env_type = "PreProduction"
  })
}

resource "harness_platform_environment_clusters_mapping" "prodenvclustermap" {
  identifier = "myprodcustomidentifier"
  org_id     = var.org_id
  project_id = var.project_id
  env_id     = harness_platform_environment.prod_environment.id
  clusters {
    identifier       = var.prod_cluster_name
    name             = var.prod_cluster_name
    agent_identifier = "project.${var.prod_agent_name}"
    scope            = "PROJECT"
  }
}

resource "harness_platform_environment_clusters_mapping" "devenvclustermap" {
  identifier = "mydevcustomidentifier"
  org_id     = var.org_id
  project_id = var.project_id
  env_id     = harness_platform_environment.dev_environment.id
  clusters {
    identifier       = var.dev_cluster_name
    name             = var.dev_cluster_name
    agent_identifier = "project.${var.dev_agent_name}"
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
    prod_environment_identifier = harness_platform_environment.prod_environment.id
    dev_environment_identifier = harness_platform_environment.dev_environment.id
    prod_cluster_name = var.prod_cluster_name
    dev_cluster_name = var.dev_cluster_name
    prod_agent_name = var.prod_agent_name
    dev_agent_name = var.dev_agent_name
    prod_application_name = var.prod_application_name
    dev_application_name = var.dev_application_name
    codebase_name = var.refservicerepo
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
    dev_values_file = var.refdevvaluesfile
    prod_values_file = var.refprodvaluesfile
    service_identifier = harness_platform_service.service.id
  })
}


