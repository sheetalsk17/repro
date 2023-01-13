# Specify the version on the AzureRM provider to use
terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "2.99.0"
    }
  }
}

# 2. Configure the AzureRM Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "MyRG201"
  location = "france central"
}

resource "azurerm_storage_account" "example" {
  name                     = "forcustomerreproodec"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_data_protection_backup_vault" "example" {
  name                = "customerbackupvaulttdec"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.example.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.example.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_blob_storage" "example" {
  name               = "customersbackuppolicyydec"
  vault_id           = azurerm_data_protection_backup_vault.example.id
  retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "example" {
  name               = "reprocustomerinstanceedec"
  vault_id           = azurerm_data_protection_backup_vault.example.id
  location           = azurerm_resource_group.example.location
  storage_account_id = azurerm_storage_account.example.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.example.id

  depends_on = [azurerm_role_assignment.example]
}