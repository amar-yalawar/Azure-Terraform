terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.8.0"
    }
  }
  required_version = ">=1.13.1"

 backend "azurerm" {
    resource_group_name   = "ado_tfstate_rg"
    storage_account_name  = "adotfstatestorageacc"
    container_name        = "adotfstatecontainer"
    key                   = "stage.terraform.tfstate"
 }

}

provider "azurerm" {

  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "adotf_rg"
  location = "Central India"
}

resource "azurerm_storage_account" "example" {

  name                     = "adotfstorageacc"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location # implicit dependency
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "production"
    managed-by = "Azure-Unix-BuildCC"
    customer = "VCI"
  }
}