variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "project" {
  type        = string
  description = "Project name for naming resources"
}

variable "env" {
  type        = string
  description = "Environment (dev/stg/prod)"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
}

variable "vm_base_name" {
  type        = string
  description = "Base name for VM (suffix will be auto-generated)"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM (use KeyVault/ADO secret in prod)"
  sensitive   = true
}

variable "vm_count" {
  type        = number
  description = "Number of VMs to provision"
}

variable "sla" {
  type        = string
  description = "SLA level for tagging"
}

variable "supported_by" {
  type        = string
  description = "Support team or owner"
}

variable "owned_by" {
  type        = string
  description = "Resource owner"
}

variable "managed_by" {
  type        = string
  description = "Managing team or function"
}

variable "state" {
  type        = string
  description = "Deployment state or lifecycle tag"
}
