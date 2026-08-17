output "folder_ids" {
  description = "Map of folder name to folder resource name (\"folders/1234\")."
  value = {
    for name, folder in google_folder.folder :
    name => folder.name
  }
}

output "folder_numeric_ids" {
  description = "Map of folder name to numeric folder ID."
  value = {
    for name, folder in google_folder.folder :
    name => trimprefix(folder.name, "folders/")
  }
}

output "project_ids" {
  description = "Map of project name to project ID."
  value = {
    for name, project in google_project.project :
    name => project.project_id
  }
}

output "project_numbers" {
  description = "Map of project name to project number."
  value = {
    for name, project in google_project.project :
    name => project.number
  }
}
