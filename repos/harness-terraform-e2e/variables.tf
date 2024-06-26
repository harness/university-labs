variable "my_harness_account_id" {
    type = string
    sensitive = true
    description = "Find your Harness Account ID under Account Settings"
}

variable "my_harness_peronal_access_token" {
    type = string
    sensitive = true
    description = "Harness Personal Access Token or Service Access Token"
    
}

variable "my_gitrepo_username" {
    type = string
    sensitive = true
    description = "Git Repo Username"
}

variable "my_gitrepo_personal_access_token" {
    type = string
    sensitive = true
    description = "Git Repo Personal Access Token"
}

variable "my_dockerhub_username" {
    type = string
    sensitive = true
    description = "DockerHub Username"
}

variable "my_dockerhub_personal_access_token" {
    type = string
    sensitive = true
    description = "DockerHub Personal Access Token"
}

variable "my_team_tag" {
    type = string
    default = "mydevteam"
    description = "Owner tag to apply to all resources"
}

variable "my_orgs" {
    type = set(string)
    default = ["my-admin-testorg"]
    description = "List of Harness Organizations to create"
}

variable "existing_org" {
    type = bool
    default = false
    description = "By default the org doesnt exist and is created. Set to true to use an existing org"
}

variable "my_projects" {
    type = set(string)
    default = ["my-admin-project"]
    description = "List of Harness Projects to create in each Organization"
}

variable "existing_project" {
    type = bool
    default = false
    description = "By default the project doesnt exist and is created. Set to true to use an existing org"
}

variable "mydomain" {
    type = string
    default = "localhost"
    description = "My Domain"
}

variable "my_project_variables" {
    type = set(map(string))
    default = [
        {
            name = "myappowner"
            fixed_value = "John Doe"
        },
        {
            name = "mycostcenter"
            fixed_value = "engineering"
        }
    ]
    description = "Harness Project level variables"
}

variable "my_dockerhub_credentials" {
    type = map(string)
    default = {
        harness_secret_name = "mycontainerregistrysecret"
        harness_secret_store = "harnessSecretManager"
        harness_secret_type = "Inline"
    }
    sensitive = true
    description = "DockerHub Credentials"
}

variable "my_genericgit_credentials" {
    type = map(string)
    default = {
        harness_secret_name = "mycodereposecret"
        harness_secret_store = "harnessSecretManager"
        harness_secret_type = "Inline"
    }
    sensitive = true
    description = "Generic Git Credentials"
}

variable "my_kubernetes_cluster_connectors" {
    type = map(map(string))
    default = {
        my_delegateauth_kubernetes_cluster = {
            name = "myk8sclusterconnector"
        }
    }
    description = "Map of Harness Kubernetes Cluster connectors"
}

variable "my_container_registy_connectors" {
    type = map(map(string))
    default = {
        my_dockerhub_container_registry = {
            name = "mycontainerregistryconnector"
            type = "DockerHub"
            url = "https://registry.hub.docker.com/v2/"
        }
    }
    description = "Map of Harness Container Registry connectors"
}
  
variable "my_code_repo_connectors" {
    type = map(map(string))
    default = {
        my_genericgit_code_repo = {
            name = "mycoderepoconnector"
            url = "https://github.com/hv-harness"
            connection_type = "Account"
            validation_repo = "k8s-infra-observability.git"
        }
    }
    description = "Map of Harness Code Repo connectors"
}

variable "my_backend_service" {
    type = string
    default = "mybackendservice"
    description = "Backend Service name to be created"
}

variable "my_frontend_service" {
    type = string
    default = "myfrontendservice"
    description = "Frontend Service name to be created"
}

variable "my_dev_environment" {
    type = string
    default = "mydevenv"
    description = "My DEV Environment"
}

variable "my_qa_environment" {
    type = string
    default = "myqaenv"
    description = "My QA Environment"
}

variable "my_prod_environment" {
    type = string
    default = "myprodenv"
    description = "My Prod Environment"
}

variable "my_dev_infrastructure" {
    type = string
    default = "mydevinfra"
    description = "My DEV Infra Kubernetes Cluster"
}

variable "my_qa_infrastructure" {
    type = string
    default = "myqainfra"
    description = "My QA Infra Kubernetes Cluster"
}

variable "my_prod_infrastructure" {
    type = string
    default = "myprodinfra"
    description = "My Prod Infra Kubernetes Cluster"
}

variable "my_pipeline" {
    type = string
    default = "mybackendpipeline"
    description = "My Pipeline to be created"
}

variable "my_inputset" {
    type = string
    default = "myinputset"
    description = "My Inputset to be created"
}

variable "my_harness_user_uuid" {
    type = string
    default = ""
    description = "My Harness User UUID"
}