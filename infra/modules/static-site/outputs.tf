output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "website_url" {
  value = azurerm_storage_account.this.primary_web_endpoint
}
