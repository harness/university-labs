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
variable "cluster_name" {}
variable "repo_name" {}
variable "repo_url" {}
variable "repo_username" {}
variable "repo_password" {}
variable "application_name" {}
variable "application_namespace" {}
variable "repo_deployment_revision" {}
variable "repo_deployment_folderpath" {}
variable "repo_deployment_valuesfilepath" {}
variable "repo_deployment_valuesoverride" {}
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

data "harness_platform_gitops_agent_deploy_yaml" "gitops_agent_yaml" {
  identifier = var.agent_name
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  namespace  = var.agent_namespace
  depends_on = [harness_platform_gitops_agent.gitops_agent]
}

resource "local_file" "gitops_agent_yaml_file" {
  filename = "${var.agent_name}_gitops_agent.yaml"
  content  = data.harness_platform_gitops_agent_deploy_yaml.gitops_agent_yaml.yaml

  depends_on =  [
                  data.harness_platform_gitops_agent_deploy_yaml.gitops_agent_yaml
                ]

}


resource "null_resource" "deploy_agent_resources_to_cluster" {
  triggers = {
    content = local_file.gitops_agent_yaml_file.content
  }

  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      set -e
      if ! kubectl get ns ${var.agent_namespace}; then
        kubectl create ns ${var.agent_namespace}
      fi
      kubectl apply -f ${var.agent_name}_gitops_agent.yaml -n ${var.agent_namespace}
      sleep 60
      kubectl rollout restart deployment gitops-agent -n ${var.agent_namespace}
    EOT
  }


  depends_on =  [
                  local_file.gitops_agent_yaml_file
                ]
}

resource "harness_platform_gitops_cluster" "gitops_cluster" {
  identifier = var.cluster_name
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  agent_id   = var.agent_name

  request {
    upsert = false
    cluster {
      server = "https://kubernetes.default.svc"
      name   = var.cluster_name
      config {
        tls_client_config {
          insecure = true
        }
        cluster_connection_type = "IN_CLUSTER"
      }

    }
  }
  depends_on = [null_resource.deploy_agent_resources_to_cluster]
}

resource "harness_platform_gitops_repository" "gitops_repo" {
  identifier = var.repo_name
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  agent_id   = var.agent_name
  repo {
    repo            = var.repo_url
    name            = var.repo_name
    username        = var.repo_username
    password        = var.repo_password
    connection_type = "HTTPS"
  }
  depends_on = [
    null_resource.deploy_agent_resources_to_cluster,
    harness_platform_gitops_cluster.gitops_cluster
    ]
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
  depends_on = [
    null_resource.deploy_agent_resources_to_cluster,
    harness_platform_gitops_cluster.gitops_cluster,
    harness_platform_gitops_repository.gitops_repo
  ]

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


