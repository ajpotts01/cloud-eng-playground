terraform {
  required_version = "~> 1.17"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.14"
    }
  }

  # No backend until bootstrapped
  # backend "azurerm" {

  # }    
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}