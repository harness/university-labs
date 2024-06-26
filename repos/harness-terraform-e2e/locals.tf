locals {

  organization_projects = distinct(flatten(
    [
      for org in var.my_orgs : [
        for project in var.my_projects : {
          org = org
          project = project
        }
      ]
    ]
  ))

  organization_projects_variables = distinct(flatten(
    [
      for org in var.my_orgs : distinct(flatten([
        for project in var.my_projects : [
          for variable in var.my_project_variables : {
            org = org
            project = project
            variable = variable
          } 
        ]
      ]))
    ]
  ))

}