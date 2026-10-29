output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "storage_account_name" {
  value = azurerm_storage_account.site.name
}

output "website_url" {
  value = azurerm_storage_account.site.primary_web_endpoint
}
