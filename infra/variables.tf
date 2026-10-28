variable "project" {
  description = "Short project name used in resource names"
  type        = string
  default     = "cloudstarter"
}

variable "environment" {
  description = "Environment name, e.g. dev or prod"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Extra tags merged onto every resource"
  type        = map(string)
  default     = {}
}
