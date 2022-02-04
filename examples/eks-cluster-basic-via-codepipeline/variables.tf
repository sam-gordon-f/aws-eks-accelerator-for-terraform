variable "environment" {
    type = string
}

variable "kubernetes_version" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "region" {
    type = string
}

variable "tenant" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "zone" {
    type = string
}