#===============================================================================
# Azure Provider
#===============================================================================

provider "azurerm" {
  version = "~> 2.0"
  features{}
}

provider "azuread" {
  version = "~> 0.8"
}

provider "local" {
  version = "> 1.0"
}

provider "null" {
  version = "> 2.0"
}

provider "random" {
  version = "> 2.0"
}

provider "template" {
  version = "> 2.0"
}

terraform {
  required_version = ">= 0.12"
}