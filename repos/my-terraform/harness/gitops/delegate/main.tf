# to run: 
# terraform init
# terraform apply -auto-approve -var="account_id=$MY_HARNESS_ACCOUNT" -var="org_id=$MY_HARNESS_ORG" -var="project_id=$MY_HARNESS_PROJECT" -var="sat=$MY_HARNESS_USER_SAT" -var="delegate_name=myproddelegate"
terraform {
    required_providers {
        harness = {
            source = "harness/harness"
            version = "~> 0.30"
        }
    }

    backend "local" {
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
variable "delegate_name" {}

resource "harness_platform_delegatetoken" "delegate_token" {
  name        = "${var.delegate_name}token${var.project_id}"
  account_id  = var.account_id
  org_id      = var.org_id
  project_id  = var.project_id
}

module "delegate" {
  source = "harness/harness-delegate/kubernetes"
  version = "0.1.8"

  account_id = var.account_id
  delegate_token = harness_platform_delegatetoken.delegate_token.value
  delegate_name = "${var.delegate_name}"
  deploy_mode = "KUBERNETES"
  namespace = "harness-delegate-ng"
  manager_endpoint = "https://app.harness.io"
  delegate_image = "harness/delegate:24.05.83001"
  replicas = 1
  upgrader_enabled = false
  values = yamlencode({
    memory : 4096
    initScript : <<-EOT
        echo "install unzip using microdnf"
        microdnf install unzip
        echo "install terraform"
        curl -sL https://releases.hashicorp.com/terraform/1.6.4/terraform_1.6.4_linux_amd64.zip -o terraform.zip
        unzip terraform.zip
        mv terraform /usr/bin/terraform
        curl -L "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=v7&source=github" | tar -zx
        mv cf7 /usr/bin/cf
    EOT
  })
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
