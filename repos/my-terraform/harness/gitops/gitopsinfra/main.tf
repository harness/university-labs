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
variable "refenvironment" {}

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
      labels = {
        "harness.io/serviceRef" = var.refservice
        "harness.io/envRef"     = var.refenvironment        
      }
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
