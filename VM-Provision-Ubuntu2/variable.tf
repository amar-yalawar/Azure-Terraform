variable "project" {
  type        = string
  description = "Project name for naming resources"
  default     = "vci"
}

variable "env" {
  type        = string
  description = "Environment (dev/stg/prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be deployed"
  default     = "Central India"
}

variable "vm_base_name" {
  type        = string
  description = "Base name for VM (suffix will be auto-generated)"
  default     = "adoappvm"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_B1s"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VM (use KeyVault/ADO secret in prod)"
  sensitive   = true
}

variable "vm_count" {
  type        = number
  description = "Number of VMs to provision"
  default     = 2
}

variable "sla" {
  type        = string
  description = "sla for naming resources"
  default     = "basic"
}

variable  "supported_by" {
  type        = string
  description = "supported_by for naming resources"
  default     = "unix_buildcc"
}

variable  "owned_by" {
  type        = string
  description = "owned_by for naming resources"
  default     = "unix-buildcc-team"
}

variable  "managed_by" {
  type        = string
  description = "managed_by for naming resources"
  default     = "group_function"
}

variable  "state" {
  type        = string
  description = "state for naming resources"
  default     = "Being Assembled"
}