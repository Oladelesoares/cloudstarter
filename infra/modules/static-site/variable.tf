variable "name" {
  description = "Globally unique storage account name"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "site_dir" {
  description = "Local folder whose files are uploaded to the website"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
