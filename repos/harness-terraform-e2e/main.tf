module "organization" {
  source = "github.com/harness-community/terraform-harness-structure.git//modules/organizations"
  for_each = var.my_orgs
  name        = each.value
  description = "resources for organization ${each.value}"
  existing = var.existing_org
  identifier = var.existing_org ? replace(each.value, "-", "_") : null
  tags = {
    my_tag = "hv"
  }
  global_tags = {
    source = "tf_modules_org"
  }
}

module "project" {
  source = "github.com/harness-community/terraform-harness-structure.git//modules/projects"
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  organization_id = module.organization[each.value.org].organization_details.id
  name            = each.value.project
  description     = "resource for the ${each.value.project} project"
  existing = var.existing_project
  identifier = var.existing_project ? replace(each.value.project, "-", "_") : null
  color           = "#ffffff"
  tags = {
    my_tag = "hv"
  }
  global_tags = {
    source = "tf_modules_project"
  }
}

resource "harness_platform_delegatetoken" "delegate_token" {  
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  name        = "my_delegate_token-${each.value.org}-${each.value.project}"
  account_id  = var.my_harness_account_id
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
}

module "delegate" {
  source = "harness/harness-delegate/kubernetes"
  version = "0.1.8"
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  account_id = var.my_harness_account_id
  delegate_token = "${harness_platform_delegatetoken.delegate_token["${each.value.org}.${each.value.project}"].value}"
  delegate_name = "mydelegate"
  deploy_mode = "KUBERNETES"
  namespace = "myharnessdelegate"
  manager_endpoint = "https://app.harness.io"
  delegate_image = "harness/delegate:24.05.83001"
  replicas = 1
  upgrader_enabled = false
  values = yamlencode({
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

resource "harness_platform_variables" "project_variables" {
    for_each        = { for idx, record in local.organization_projects_variables : idx => record }
    org_id          = module.organization[each.value.org].organization_details.id
    project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
    name       = each.value.variable.name
    identifier = replace(each.value.variable.name, "-", "_")
    description = "Project level variables for ${each.value.project} in org ${each.value.org}"
    type       = "String"
    spec {
        value_type  = "FIXED"
        fixed_value = each.value.variable.fixed_value
    }
}

resource "harness_platform_variables" "mydomain" {
    for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
    org_id          = module.organization[each.value.org].organization_details.id
    project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
    name       = "mydomain"
    identifier = "mydomain"
    description = "mydomain variable for ${each.value.project} in org ${each.value.org}"
    type       = "String"
    spec {
        value_type  = "FIXED"
        fixed_value = var.mydomain
    }
}

resource "harness_platform_secret_text" "secret_tas_inline" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mytassecret"
  identifier  = "mytassecret"
  description = "TAS Secret for project ${each.value.project} in org ${each.value.org}"
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = "1harness"
}

resource "harness_platform_secret_text" "secret_genericgit_hsm_inline" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_genericgit_credentials["harness_secret_name"]
  identifier  = replace(var.my_genericgit_credentials["harness_secret_name"], "-", "_")
  description = "Generic Git Code Repo Secret for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  secret_manager_identifier = var.my_genericgit_credentials["harness_secret_store"]
  value_type                = var.my_genericgit_credentials["harness_secret_type"]
  value                     = var.my_gitrepo_personal_access_token
}

resource "harness_platform_secret_text" "secret_dockerhub_hsm_inline" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_dockerhub_credentials["harness_secret_name"]
  identifier  = replace(var.my_dockerhub_credentials["harness_secret_name"], "-", "_")
  description = "DockerHub Container Registry Secret for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  secret_manager_identifier = var.my_dockerhub_credentials["harness_secret_store"]
  value_type                = var.my_dockerhub_credentials["harness_secret_type"]
  value                     = var.my_dockerhub_personal_access_token
}

resource "harness_platform_connector_kubernetes" "connector_kubernetes_delegateauth" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_kubernetes_cluster_connectors["my_delegateauth_kubernetes_cluster"].name
  identifier  = replace(var.my_kubernetes_cluster_connectors["my_delegateauth_kubernetes_cluster"].name, "-", "_")
  description = "Kubernetes Cluster connector via delegate auth for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  inherit_from_delegate {
    delegate_selectors = ["mydelegate"]
  }
}

resource "harness_platform_connector_git" "connector_code_repo_genericgit" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_code_repo_connectors["my_genericgit_code_repo"].name
  identifier  = replace(var.my_code_repo_connectors["my_genericgit_code_repo"].name, "-", "_")
  description = "Generic git code repo connector for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  url                = var.my_code_repo_connectors["my_genericgit_code_repo"].url
  connection_type    = var.my_code_repo_connectors["my_genericgit_code_repo"].connection_type
  validation_repo    = var.my_code_repo_connectors["my_genericgit_code_repo"].validation_repo
  #delegate_selectors  = ["mydelegate"]
  #execute_on_delegate = false
  credentials {
    http {
      username     = var.my_gitrepo_username
      password_ref = "${harness_platform_secret_text.secret_genericgit_hsm_inline["${each.value.org}.${each.value.project}"].id}"
    }
  }
}

resource "harness_platform_connector_docker" "connector_container_registry_dockerhub" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_container_registy_connectors["my_dockerhub_container_registry"].name
  identifier  = replace(var.my_container_registy_connectors["my_dockerhub_container_registry"].name, "-", "_")
  description = "Dockerhub Container Registry connector for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  type               = var.my_container_registy_connectors["my_dockerhub_container_registry"].type
  url                = var.my_container_registy_connectors["my_dockerhub_container_registry"].url
  #delegate_selectors  = ["mydelegate"]
  execute_on_delegate = false
  credentials {
    username     = var.my_dockerhub_username
    password_ref = "${harness_platform_secret_text.secret_dockerhub_hsm_inline["${each.value.org}.${each.value.project}"].id}"
  }
}

resource "harness_platform_service" "frontend_service" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_frontend_service
  identifier  = replace(var.my_frontend_service, "-", "_")
  description = "My Frontend Service for project ${each.value.project} in org ${each.value.org}"
  tags        = ["team:${var.my_team_tag}"]
  yaml = <<-EOT
                service:
                  name: ${var.my_frontend_service}
                  identifier: ${replace(var.my_frontend_service, "-", "_")} 
                  serviceDefinition:
                    spec:
                      manifests:
                        - manifest:
                            identifier: myfrontendservicek8smanifests
                            type: K8sManifest
                            spec:
                              store:
                                type: Git
                                spec:
                                  connectorRef: ${harness_platform_connector_git.connector_code_repo_genericgit["${each.value.org}.${each.value.project}"].id}
                                  gitFetchType: Branch
                                  paths: <+input>
                                  repoName: <+input> 
                                  branch: main
                              valuesPaths: <+input>
                              skipResourceVersioning: false
                      variables: 
                        - name: containerport
                          type: String
                          value: 3000
                          description: the port exposed by the container
                        - name: serviceport
                          type: String
                          value: 3000
                          description: the port exposed by the service
                        - name: nodeport
                          type: String
                          value: 30005
                          description: the port exposed by the node
                        - name: servicetype
                          type: String
                          value: LoadBalancer
                          description: the type of service can be LoadBalancer, NodePort, ClusterIP
                      artifacts:
                        primary:
                          sources:
                            - spec:
                                connectorRef: ${harness_platform_connector_docker.connector_container_registry_dockerhub["${each.value.org}.${each.value.project}"].id}
                                imagePath: <+input>
                                tag: <+input>
                                digest: ""
                              identifier: myfrontendserviceartifact
                              type: DockerRegistry
                          primaryArtifactRef: <+input>
                    type: Kubernetes
                  gitOpsEnabled: false
              EOT
}

resource "harness_platform_service" "backend_service" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_backend_service
  identifier  = replace(var.my_backend_service, "-", "_")
  description = "My Service for project ${each.value.project} in org ${each.value.org}"
  tags        = ["team:${var.my_team_tag}"]
  yaml = <<-EOT
                service:
                  name: ${var.my_backend_service}
                  identifier: ${replace(var.my_backend_service, "-", "_")} 
                  serviceDefinition:
                    spec:
                      manifests:
                        - manifest:
                            identifier: mybackendservicek8smanifests
                            type: K8sManifest
                            spec:
                              store:
                                type: Git
                                spec:
                                  connectorRef: ${harness_platform_connector_git.connector_code_repo_genericgit["${each.value.org}.${each.value.project}"].id}
                                  gitFetchType: Branch
                                  paths: <+input>
                                  repoName: <+input> 
                                  branch: main
                              valuesPaths: <+input>
                              skipResourceVersioning: false
                      variables: 
                        - name: containerport
                          type: String
                          value: 8080
                          description: the port exposed by the container
                        - name: serviceport
                          type: String
                          value: 8080
                          description: the port exposed by the service
                        - name: nodeport
                          type: String
                          value: <+input>
                          description: the port exposed by the node
                        - name: servicetype
                          type: String
                          value: LoadBalancer
                          description: the type of service can be LoadBalancer, NodePort, ClusterIP
                      artifacts:
                        primary:
                          sources:
                            - spec:
                                connectorRef: ${harness_platform_connector_docker.connector_container_registry_dockerhub["${each.value.org}.${each.value.project}"].id}
                                imagePath: <+input>
                                tag: <+input>
                                digest: ""
                              identifier: mybackendserviceartifact
                              type: DockerRegistry
                          primaryArtifactRef: <+input>
                    type: Kubernetes
                  gitOpsEnabled: false
              EOT
}

resource "harness_platform_environment" "dev_env" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_dev_environment
  identifier  = replace(var.my_dev_environment, "-", "_")
  description = "My dev Environment for project ${each.value.project} in org ${each.value.org}"
  type       = "PreProduction"

  yaml = <<-EOT
      environment:
         name: ${var.my_dev_environment}
         identifier: ${replace(var.my_dev_environment, "-", "_")}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         type: PreProduction
  EOT
}

resource "harness_platform_environment" "qa_env" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_qa_environment
  identifier  = replace(var.my_qa_environment, "-", "_")
  description = "My qa Environment for project ${each.value.project} in org ${each.value.org}"
  type       = "PreProduction"

  yaml = <<-EOT
      environment:
         name: ${var.my_qa_environment}
         identifier: ${replace(var.my_qa_environment, "-", "_")}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         type: PreProduction
  EOT
}

resource "harness_platform_environment" "prod_env" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_prod_environment
  identifier  = replace(var.my_prod_environment, "-", "_")
  description = "My Prod Environment for project ${each.value.project} in org ${each.value.org}"
  type       = "Production"

  yaml = <<-EOT
      environment:
         name: ${var.my_prod_environment}
         identifier: ${replace(var.my_prod_environment, "-", "_")}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         type: Production
  EOT
}

resource "harness_platform_infrastructure" "dev_infrastructure" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_dev_infrastructure
  identifier  = replace(var.my_dev_infrastructure, "-", "_")
  description = "My dev Infra for project ${each.value.project} in org ${each.value.org}"
  env_id          = harness_platform_environment.dev_env["${each.value.org}.${each.value.project}"].id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
        infrastructureDefinition:
         name: ${var.my_dev_infrastructure} 
         identifier: ${replace(var.my_dev_infrastructure, "-", "_")}
         description: "dev kubernetes cluster"
         tags: {}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         environmentRef: ${harness_platform_environment.dev_env["${each.value.org}.${each.value.project}"].id}
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: <+input>
          namespace: "mydev"
          releaseName: release-<+INFRA_KEY_SHORT_ID>
         allowSimultaneousDeployments: true
      EOT
}

resource "harness_platform_infrastructure" "qa_infrastructure" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_qa_infrastructure
  identifier  = replace(var.my_qa_infrastructure, "-", "_")
  description = "My qa Infra for project ${each.value.project} in org ${each.value.org}"
  env_id          = harness_platform_environment.qa_env["${each.value.org}.${each.value.project}"].id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
        infrastructureDefinition:
         name: ${var.my_qa_infrastructure} 
         identifier: ${replace(var.my_qa_infrastructure, "-", "_")}
         description: "qa kubernetes cluster"
         tags: {}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         environmentRef: ${harness_platform_environment.qa_env["${each.value.org}.${each.value.project}"].id}
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: ${harness_platform_connector_kubernetes.connector_kubernetes_delegateauth["${each.value.org}.${each.value.project}"].id}
          namespace: "myqa"
          releaseName: release-<+INFRA_KEY_SHORT_ID>
         allowSimultaneousDeployments: true
      EOT
}

resource "harness_platform_infrastructure" "prod_infrastructure" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_prod_infrastructure
  identifier  = replace(var.my_prod_infrastructure, "-", "_")
  description = "My Prod Infra for project ${each.value.project} in org ${each.value.org}"
  env_id          = harness_platform_environment.qa_env["${each.value.org}.${each.value.project}"].id
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"
  yaml            = <<-EOT
        infrastructureDefinition:
         name: ${var.my_prod_infrastructure} 
         identifier: ${replace(var.my_prod_infrastructure, "-", "_")}
         description: "production kubernetes cluster"
         tags: {}
         orgIdentifier: ${module.organization[each.value.org].organization_details.id}
         projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
         environmentRef: ${harness_platform_environment.prod_env["${each.value.org}.${each.value.project}"].id}
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: ${harness_platform_connector_kubernetes.connector_kubernetes_delegateauth["${each.value.org}.${each.value.project}"].id}
          namespace: "myprod"
          releaseName: release-<+INFRA_KEY_SHORT_ID>
         allowSimultaneousDeployments: true
      EOT
}

resource "harness_platform_pipeline" "pipeline" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_pipeline
  identifier  = replace(var.my_pipeline, "-", "_")
  description = "My Pipeline for project ${each.value.project} in org ${each.value.org}"
  yaml = <<-EOT
      pipeline:
          name: ${var.my_pipeline}
          identifier: ${replace(var.my_pipeline, "-", "_")}
          projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
          orgIdentifier: ${module.organization[each.value.org].organization_details.id}
          tags: {}
          stages:
            - stage:
                name: mybuild
                identifier: mybuild
                description: ""
                type: CI
                spec:
                  cloneCodebase: true
                  platform:
                    os: Linux
                    arch: Amd64
                  runtime:
                    type: Cloud
                    spec: {}
                  execution:
                    steps:
                      - step:
                          type: RunTests
                          name: Compile and Unit Test
                          identifier: Compile_and_Unit_Test
                          spec:
                            connectorRef: mycontainerregistryconnector
                            image: harbor.${var.mydomain}/library/maven:3-eclipse-temurin-17
                            language: Java
                            buildTool: Maven
                            args: clean test
                            runOnlySelectedTests: true
                            reports:
                              type: JUnit
                              spec:
                                paths:
                                  - "**/*.xml"
                            resources:
                              limits:
                                memory: 2Gi
                                cpu: "1"
                            enableTestSplitting: false
                      - step:
                          type: Run
                          name: Build Executable
                          identifier: Build_Executable
                          spec:
                            connectorRef: mycontainerregistryconnector
                            image: harbor.${var.mydomain}/library/maven:3-eclipse-temurin-17
                            shell: Sh
                            command: mvn -Dmaven.test.skip=true clean install
                            resources:
                              limits:
                                memory: 2Gi
                                cpu: "1"
                      - step:
                          type: BuildAndPushDockerRegistry
                          name: Containerize and Push Image to Registry
                          identifier: Containerize_and_Push_Image_to_Registry
                          spec:
                            connectorRef: mycontainerregistryconnector
                            repo: harbor.${var.mydomain}/library/my-backend-service
                            tags: <+input>
                            resources:
                              limits:
                                memory: 2Gi
                                cpu: "1"
                  caching:
                    enabled: false
                    paths: []
            - stage:
                name: myqadeploy
                identifier: myqadeploy
                description: ""
                type: Deployment
                spec:
                  deploymentType: Kubernetes
                  service:
                    serviceRef: mybackendservice
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          manifests:
                            - manifest:
                                identifier: mybackendservicek8smanifests
                                type: K8sManifest
                                spec:
                                  store:
                                    type: Git
                                    spec:
                                      paths: <+input>
                                      repoName: <+input>
                                  valuesPaths: <+input>
                          variables:
                            - name: nodeport
                              type: String
                              value: <+input>
                          artifacts:
                            primary:
                              primaryArtifactRef: <+input>
                              sources: <+input>
                  environment:
                    environmentRef: myqaenv
                    deployToAll: false
                    infrastructureDefinitions:
                      - identifier: myqainfra
                  execution:
                    steps:
                      - step:
                          name: Rollout Deployment
                          identifier: rolloutDeployment
                          type: K8sRollingDeploy
                          timeout: 10m
                          spec:
                            skipDryRun: false
                            pruningEnabled: false
                    rollbackSteps:
                      - step:
                          name: Rollback Rollout Deployment
                          identifier: rollbackRolloutDeployment
                          type: K8sRollingRollback
                          timeout: 10m
                          spec:
                            pruningEnabled: false
                tags: {}
                failureStrategies:
                  - onFailure:
                      errors:
                        - AllErrors
                      action:
                        type: StageRollback
            - stage:
                name: myusertest
                identifier: myusertest
                description: ""
                type: Custom
                spec:
                  execution:
                    steps:
                      - step:
                          type: Wait
                          name: Ingress Readiness Wait
                          identifier: Ingress_Readiness_Wait
                          spec:
                            duration: 2m
                      - step:
                          type: Http
                          name: "Validate API Availability "
                          identifier: Validate_API_Availability
                          spec:
                            url: https://mybackendservice-myqa.<+variable.mydomain>/api/v1/configinfo
                            method: GET
                            headers: []
                            inputVariables: []
                            outputVariables: []
                            assertion: <+httpResponseCode> == 200
                          timeout: 30s
                tags: {}
            - stage:
                name: myapproval
                identifier: myapproval
                description: ""
                type: Approval
                spec:
                  execution:
                    steps:
                      - step:
                          name: myprodapproval
                          identifier: myprodapproval
                          type: HarnessApproval
                          timeout: 1d
                          spec:
                            approvalMessage: |-
                              Please review the following information
                              and approve the pipeline progression
                            includePipelineExecutionHistory: true
                            approvers:
                              minimumCount: 1
                              disallowPipelineExecutor: false
                              userGroups:
                                - _project_all_users
                            isAutoRejectEnabled: false
                            approverInputs: []
                tags: {}
            - stage:
                name: myproddeploy
                identifier: myproddeploy
                description: ""
                type: Deployment
                spec:
                  deploymentType: Kubernetes
                  service:
                    serviceRef: mybackendservice
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          manifests:
                            - manifest:
                                identifier: mybackendservicek8smanifests
                                type: K8sManifest
                                spec:
                                  store:
                                    type: Git
                                    spec:
                                      paths: <+input>
                                      repoName: <+input>
                                  valuesPaths: <+input>
                          variables:
                            - name: nodeport
                              type: String
                              value: <+input>
                          artifacts:
                            primary:
                              primaryArtifactRef: <+input>
                              sources: <+input>
                  environment:
                    environmentRef: myprodenv
                    deployToAll: false
                    infrastructureDefinitions:
                      - identifier: myprodinfra
                  execution:
                    steps:
                      - step:
                          name: Rollout Deployment
                          identifier: rolloutDeployment
                          type: K8sRollingDeploy
                          timeout: 10m
                          spec:
                            skipDryRun: false
                            pruningEnabled: false
                    rollbackSteps:
                      - step:
                          name: Rollback Rollout Deployment
                          identifier: rollbackRolloutDeployment
                          type: K8sRollingRollback
                          timeout: 10m
                          spec:
                            pruningEnabled: false
                tags: {}
                failureStrategies:
                  - onFailure:
                      errors:
                        - AllErrors
                      action:
                        type: StageRollback
          variables:
            - name: replicacount
              type: Number
              description: ""
              required: false
              value: <+input>
          properties:
            ci:
              codebase:
                connectorRef: mycoderepoconnector
                repoName: my-backend-service.git
                build: <+input>
  EOT
}

resource "harness_platform_input_set" "inputset" {
  for_each = { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry }
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = var.my_inputset
  identifier  = replace(var.my_inputset, "-", "_")
  description = "My Inputset for project ${each.value.project} in org ${each.value.org}"
  pipeline_id = "${harness_platform_pipeline.pipeline["${each.value.org}.${each.value.project}"].id}"
  yaml        = <<-EOT
      inputSet:
        name: ${var.my_inputset}
        identifier: ${replace(var.my_inputset, "-", "_")}
        projectIdentifier: ${module.project["${each.value.org}.${each.value.project}"].project_details.id}
        orgIdentifier: ${module.organization[each.value.org].organization_details.id}
        pipeline:
          identifier: ${harness_platform_pipeline.pipeline["${each.value.org}.${each.value.project}"].id}
          stages:
            - stage:
                identifier: mybuild
                type: CI
                spec:
                  execution:
                    steps:
                      - step:
                          identifier: Containerize_and_Push_Image_to_Registry
                          type: BuildAndPushDockerRegistry
                          spec:
                            tags:
                              - v2.0.0
            - stage:
                identifier: myqadeploy
                type: Deployment
                spec:
                  service:
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          manifests:
                            - manifest:
                                identifier: mybackendservicek8smanifests
                                type: K8sManifest
                                spec:
                                  store:
                                    type: Git
                                    spec:
                                      paths:
                                        - /deployment/harness/templates/
                                      repoName: my-backend-service.git
                                  valuesPaths:
                                    - /deployment/harness/qa-values.yaml
                          variables:
                            - name: nodeport
                              type: String
                              value: "30015"
                          artifacts:
                            primary:
                              primaryArtifactRef: mybackendserviceartifact
                              sources:
                                - identifier: mybackendserviceartifact
                                  type: DockerRegistry
                                  spec:
                                    imagePath: library/my-backend-service
                                    tag: v2.0.0
            - stage:
                identifier: myproddeploy
                type: Deployment
                spec:
                  service:
                    serviceInputs:
                      serviceDefinition:
                        type: Kubernetes
                        spec:
                          manifests:
                            - manifest:
                                identifier: mybackendservicek8smanifests
                                type: K8sManifest
                                spec:
                                  store:
                                    type: Git
                                    spec:
                                      paths:
                                        - /deployment/harness/templates/
                                      repoName: my-backend-service.git
                                  valuesPaths:
                                    - /deployment/harness/prod-values.yaml
                          variables:
                            - name: nodeport
                              type: String
                              value: "30025"
                          artifacts:
                            primary:
                              primaryArtifactRef: mybackendserviceartifact
                              sources:
                                - identifier: mybackendserviceartifact
                                  type: DockerRegistry
                                  spec:
                                    imagePath: library/my-backend-service
                                    tag: v2.0.0
          variables:
            - name: replicacount
              type: Number
              value: 1
          properties:
            ci:
              codebase:
                build:
                  type: branch
                  spec:
                    branch: main
  EOT
}

# --------------------------------------
# CI ILT
# --------------------------------------

resource "harness_platform_service_account" "mysvcact" {
  for_each = (var.use_ci_ilt || var.use_cd_ilt_gitops) ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  account_id  = var.my_harness_account_id
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
  identifier  = "mysvcact"
  name        = "mysvcact"
  email       = "mysvcact@service.harness.io"
  description = "mysvcact"
}

resource "harness_platform_role_assignments" "mysvcactrole" {
  for_each = (var.use_ci_ilt || var.use_cd_ilt_gitops) ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
  resource_group_identifier = "_all_project_level_resources"
  role_identifier           = "_project_admin"
  principal {
    identifier = harness_platform_service_account.mysvcact["${each.value.org}.${each.value.project}"].id
    type       = "SERVICE_ACCOUNT"
  }
  disabled = false
  managed  = false
}

resource "harness_platform_apikey" "mysvcactkey" {
  for_each = (var.use_ci_ilt || var.use_cd_ilt_gitops) ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  account_id  = var.my_harness_account_id
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
  identifier  = "mysvcactkey"
  name        = "mysvcactkey"
  parent_id   = harness_platform_service_account.mysvcact["${each.value.org}.${each.value.project}"].id
  apikey_type = "SERVICE_ACCOUNT"
}

resource "harness_platform_token" "mysvcacttoken" {
  for_each = (var.use_ci_ilt || var.use_cd_ilt_gitops) ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  account_id  = var.my_harness_account_id
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
  identifier  = "mysvcacttoken"
  name        = "mysvcacttoken"
  parent_id   = harness_platform_service_account.mysvcact["${each.value.org}.${each.value.project}"].id
  apikey_type = "SERVICE_ACCOUNT"
  apikey_id   = harness_platform_apikey.mysvcactkey["${each.value.org}.${each.value.project}"].id
}

# resource "harness_platform_apikey" "myuserkey" {
#   for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
#   account_id  = var.my_harness_account_id
#   org_id      = module.organization[each.value.org].organization_details.id
#   project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
#   identifier  = "myuserkey"
#   name        = "myuserkey"
#   parent_id   = var.my_harness_user_uuid
#   apikey_type = "USER"
# }

# resource "harness_platform_token" "myusertoken" {
#   for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
#   account_id  = var.my_harness_account_id
#   org_id      = module.organization[each.value.org].organization_details.id
#   project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
#   identifier  = "myusertoken"
#   name        = "myusertoken"
#   parent_id   = var.my_harness_user_uuid
#   apikey_type = "USER"
#   apikey_id   = "myuserkey"
# }

# output "mysvcactt" {
#   value       = harness_platform_token.mysvcacttoken[0].value
#   sensitive   = true
# }

resource "harness_platform_pipeline" "ci_pipeline" {
  for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mybasecipipeline"
  identifier  = "mybasecipipeline"
  description = "My Base CI Pipeline for project ${each.value.project} in org ${each.value.org}"
  yaml = templatefile("yamlfiles/ci-day1-base-pipeline.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    pipeline_name = "mybasecipipeline"
    pipeline_identifier = "mybasecipipeline"
  })
}

variable "use_ci_ilt" {
  type    = bool
  default = false
}

resource "null_resource" "ci_ilt" {
  count = var.use_ci_ilt ? 1 : 0

  depends_on = [
    harness_platform_delegatetoken.delegate_token,
    module.delegate,
    harness_platform_secret_text.secret_dockerhub_hsm_inline,
    harness_platform_connector_kubernetes.connector_kubernetes_delegateauth,
    harness_platform_connector_docker.connector_container_registry_dockerhub,
    harness_platform_variables.mydomain,
    harness_platform_service_account.mysvcact,
    harness_platform_role_assignments.mysvcactrole,
    harness_platform_apikey.mysvcactkey,
    harness_platform_token.mysvcacttoken,
    # harness_platform_apikey.myuserkey,
    # harness_platform_token.myusertoken,
    harness_platform_pipeline.ci_pipeline
  ] 
}

resource "harness_platform_pipeline" "ci_pipeline_day_two" {
  for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mybasecipipeline"
  identifier  = "mybasecipipeline"
  description = "My Base CI Pipeline for project ${each.value.project} in org ${each.value.org}"
  yaml = templatefile("yamlfiles/ci-day2-base-pipeline.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    pipeline_name = "mybasecipipeline"
    pipeline_identifier = "mybasecipipeline"
  })
}

resource "harness_platform_input_set" "ci_myinputset_day_two" {
  for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "myinputset"
  identifier  = "myinputset"
  description = "My Inputset for project ${each.value.project} in org ${each.value.org}"
  pipeline_id = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  yaml = templatefile("yamlfiles/ci-day2-myinputset.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    inputset_name = "myinputset"
    inputset_identifier = "myinputset"
    pipeline_identifier = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  })
}

resource "harness_platform_input_set" "ci_myinputsetgittrigger_day_two" {
  for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "myinputsetgittrigger"
  identifier  = "myinputsetgittrigger"
  description = "My Inputsetgittrigger for project ${each.value.project} in org ${each.value.org}"
  pipeline_id = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  yaml = templatefile("yamlfiles/ci-day2-myinputsetgittrigger.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    inputset_name = "myinputsetgittrigger"
    inputset_identifier = "myinputsetgittrigger"
    pipeline_identifier = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  })
}

resource "harness_platform_triggers" "ci_gittrigger_day_two" {
  for_each = var.use_ci_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name          = "mygittrigger"
  identifier    = "mygittrigger"
  target_id     = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  yaml          = templatefile("yamlfiles/ci-day2-mygittrigger.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    trigger_name = "mygittrigger"
    trigger_identifier = "mygittrigger"
    inputset_identifier = "${harness_platform_input_set.ci_myinputsetgittrigger_day_two["${each.value.org}.${each.value.project}"].id}"
    pipeline_identifier = "${harness_platform_pipeline.ci_pipeline_day_two["${each.value.org}.${each.value.project}"].id}"
  })
}

resource "null_resource" "ci_ilt_day_two" {
  count = var.use_ci_ilt ? 1 : 0

  depends_on = [
    harness_platform_delegatetoken.delegate_token,
    module.delegate,
    harness_platform_secret_text.secret_dockerhub_hsm_inline,
    harness_platform_connector_kubernetes.connector_kubernetes_delegateauth,
    harness_platform_connector_docker.connector_container_registry_dockerhub,
    harness_platform_variables.mydomain,
    harness_platform_service_account.mysvcact,
    harness_platform_role_assignments.mysvcactrole,
    harness_platform_apikey.mysvcactkey,
    harness_platform_token.mysvcacttoken,
    # harness_platform_apikey.myuserkey,
    # harness_platform_token.myusertoken,
    harness_platform_pipeline.ci_pipeline_day_two,
    harness_platform_input_set.ci_myinputset_day_two,
    harness_platform_input_set.ci_myinputsetgittrigger_day_two,
    harness_platform_triggers.ci_gittrigger_day_two
  ] 
}

# --------------------------------------
# STO ILT
# --------------------------------------

variable "use_sto_ilt" {
  type    = bool
  default = false
}

resource "null_resource" "sto_ilt_day_one" {
  count = var.use_sto_ilt ? 1 : 0

  depends_on = [
    harness_platform_delegatetoken.delegate_token,
    module.delegate,
    harness_platform_secret_text.secret_dockerhub_hsm_inline,
    harness_platform_connector_kubernetes.connector_kubernetes_delegateauth,
    harness_platform_connector_docker.connector_container_registry_dockerhub,
    harness_platform_variables.mydomain,
    # harness_platform_service_account.mysvcact,
    # harness_platform_role_assignments.mysvcactrole,
    # harness_platform_apikey.mysvcactkey,
    # harness_platform_token.mysvcacttoken,
    # harness_platform_apikey.myuserkey,
    # harness_platform_token.myusertoken,
    harness_platform_pipeline.sto_pipeline_day_one,
  ] 
}

resource "harness_platform_pipeline" "sto_pipeline_day_one" {
  for_each = var.use_sto_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mystopipeline"
  identifier  = "mystopipeline"
  description = "My STO Pipeline for project ${each.value.project} in org ${each.value.org}"
  yaml = templatefile("yamlfiles/sto-day1-base-pipeline.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    pipeline_name = "mystopipeline"
    pipeline_identifier = "mystopipeline"
  })
}

resource "null_resource" "sto_ilt_day_two" {
  count = var.use_sto_ilt ? 1 : 0

  depends_on = [
    harness_platform_delegatetoken.delegate_token,
    module.delegate,
    harness_platform_secret_text.secret_dockerhub_hsm_inline,
    harness_platform_connector_kubernetes.connector_kubernetes_delegateauth,
    harness_platform_connector_docker.connector_container_registry_dockerhub,
    harness_platform_variables.mydomain,
    # harness_platform_service_account.mysvcact,
    # harness_platform_role_assignments.mysvcactrole,
    # harness_platform_apikey.mysvcactkey,
    # harness_platform_token.mysvcacttoken,
    # harness_platform_apikey.myuserkey,
    # harness_platform_token.myusertoken,
    harness_platform_pipeline.sto_pipeline_day_two,
  ] 
}

resource "harness_platform_pipeline" "sto_pipeline_day_two" {
  for_each = var.use_sto_ilt ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mystopipeline"
  identifier  = "mystopipeline"
  description = "My STO Pipeline for project ${each.value.project} in org ${each.value.org}"
  yaml = templatefile("yamlfiles/sto-day2-base-pipeline.yaml", {
    org_identifier = each.value.org
    project_identifier = each.value.project
    pipeline_name = "mystopipeline"
    pipeline_identifier = "mystopipeline"
  })
}

# --------------------------------------
# CD GitOps ILT
# --------------------------------------

variable "use_cd_ilt_gitops" {
  type    = bool
  default = false
}

resource "null_resource" "cd_ilt_gitops_day_one" {
  count = var.use_cd_ilt_gitops ? 1 : 0

  depends_on = [
    harness_platform_delegatetoken.delegate_token_cd_gitops,
    module.delegate_cd_gitops,
    harness_platform_secret_text.secret_dockerhub_hsm_inline,
    #harness_platform_connector_kubernetes.connector_kubernetes_delegateauth,
    harness_platform_connector_docker.connector_container_registry_dockerhub,
    harness_platform_variables.mydomain,
    harness_platform_service_account.mysvcact,
    harness_platform_role_assignments.mysvcactrole,
    harness_platform_apikey.mysvcactkey,
    harness_platform_token.mysvcacttoken,
    harness_platform_secret_text.secret_satokenvalue_hsm_inline_cd_gitops,
    # harness_platform_apikey.myuserkey,
    # harness_platform_token.myusertoken,
  ] 
}

resource "harness_platform_delegatetoken" "delegate_token_cd_gitops" {  
  for_each = var.use_cd_ilt_gitops ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  name        = "my_delegate_token-${each.value.org}-${each.value.project}"
  account_id  = var.my_harness_account_id
  org_id      = module.organization[each.value.org].organization_details.id
  project_id  = module.project["${each.value.org}.${each.value.project}"].project_details.id
}

module "delegate_cd_gitops" {
  for_each = var.use_cd_ilt_gitops ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  source = "harness/harness-delegate/kubernetes"
  version = "0.1.8"
  account_id = var.my_harness_account_id
  delegate_token = "${harness_platform_delegatetoken.delegate_token_cd_gitops["${each.value.org}.${each.value.project}"].value}"
  delegate_name = "mydevdelegate"
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

resource "harness_platform_secret_text" "secret_satokenvalue_hsm_inline_cd_gitops" {
  for_each = var.use_cd_ilt_gitops ? { for entry in local.organization_projects : "${entry.org}.${entry.project}" => entry } : {}
  org_id = module.organization[each.value.org].organization_details.id
  project_id      = module.project["${each.value.org}.${each.value.project}"].project_details.id
  name        = "mysatokenvalue"
  identifier  = "mysatokenvalue"
  description = "Service Account token value secret for project ${each.value.project} in org ${each.value.org}"
  tags        = [var.my_team_tag]
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = harness_platform_token.mysvcacttoken["${each.value.org}.${each.value.project}"].value
}
