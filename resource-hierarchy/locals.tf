locals {
  # Flatten each project's inline services list into a single flat map, one
  # entry per API, so the service resource can use one for_each with no nesting.
  project_services = merge([
    for project_key, project in var.projects : {
      for service in project.services :
      "${project_key}:${service}" => {
        project_key = project_key
        service     = service
      }
    }
  ]...)
}
