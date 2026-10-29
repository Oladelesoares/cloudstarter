locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge({
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }, var.tags)
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}


# Storage account names are global across all of Azure, so add a random suffix
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "site" {
  name                            = "st${var.project}${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

# One blob per file; content_md5 makes Terraform re-upload when a file changes
resource "azurerm_storage_blob" "pages" {
  for_each = toset(["index.html", "404.html"])

  name                   = each.key
  storage_account_name   = azurerm_storage_account.site.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.root}/../site/${each.key}"
  content_type           = "text/html"
  content_md5            = filemd5("${path.root}/../site/${each.key}")

  depends_on = [azurerm_storage_account_static_website.site]
}

