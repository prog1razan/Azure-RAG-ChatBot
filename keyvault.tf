data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = "${local.resource_name_prefix}-kv-${random_string.myrandom.id}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  rbac_authorization_enabled = false

  tags = local.common_tags
}


resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}


resource "azurerm_key_vault_access_policy" "vm" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.web_vm.identity[0].principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

output "key_vault_name" {
  description = "Key Vault Name"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.kv.vault_uri
}