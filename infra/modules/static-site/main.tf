locals {
  files = fileset(var.site_dir, "**")
  mime = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    svg  = "image/svg+xml"
  }
}

resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_storage_account_static_website" "this" {
  storage_account_id = azurerm_storage_account.this.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

resource "azurerm_storage_blob" "pages" {
  for_each = local.files

  name                   = each.key
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${var.site_dir}/${each.key}"
  content_type           = lookup(local.mime, reverse(split(".", each.key))[0], "application/octet-stream")
  content_md5            = filemd5("${var.site_dir}/${each.key}")

  depends_on = [azurerm_storage_account_static_website.this]
}
