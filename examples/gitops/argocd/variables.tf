variable "cluster_version" {
  type        = string
  description = "Kubernetes Version"
  default     = "1.21"
}

variable "tenant" {
  type        = string
  description = "Account Name or unique account unique id e.g., apps or management or aws007"
  default     = "aws001"
}

variable "environment" {
  type        = string
  default     = "preprod"
  description = "Environment area, e.g. prod or preprod "
}

variable "zone" {
  type        = string
  description = "Zone, e.g. dev or qa or load or ops etc..."
  default     = "dev"
}

variable "region" {
  type        = string
  description = "Region in which to deploy the cluster"
  default     = "us-west-2"
}