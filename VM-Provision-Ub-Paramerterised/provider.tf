terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.8.0"
    }
  }

  required_version = ">= 1.3.0"

  backend "azurerm" {
    resource_group_name   = "ado_tfstate_rg"
    storage_account_name  = "adotfstatestorageacc"
    container_name        = "adotfstatecontainer"
    key                   = "vmss.dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}
