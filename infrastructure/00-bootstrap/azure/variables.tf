variable "project_name" {
  type        = string
  description = "Project name. Used for resource names."
}

variable "region" {
  type        = string
  description = "Region to use for resources."
  default     = "australiaeast"
}

variable "github_repo_id" {
  type        = string
  description = "Github repo ID - used for federated credentials"
}

variable "github_repo_owner_id" {
  type        = string
  description = "Github repo owner ID - used for federated credentials"
}