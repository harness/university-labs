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
  identifier = "${harness_platform_gitops_agent.gitops_agent.identifier}"
  account_id = var.account_id
  project_id = var.project_id
  org_id     = var.org_id
  namespace  = var.agent_namespace
}

resource "local_file" "gitops_agent_yaml_file" {
  filename = "gitops_agent.yaml"
  content  = data.harness_platform_gitops_agent_deploy_yaml.gitops_agent_yaml.yaml
}

resource "null_resource" "deploy_agent_resources_to_cluster" {
  triggers = {
    content = local_file.gitops_agent_yaml_file.content
  }
  provisioner "local-exec" {
    when = create
    command = "kubectl create ns ${var.agent_namespace} && kubectl apply -f gitops_agent.yaml -n ${var.agent_namespace} && sleep 60"
  }
  depends_on = [local_file.gitops_agent_yaml_file]
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


