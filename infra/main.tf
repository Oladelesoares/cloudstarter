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

module "static_site" {
  source              = "./modules/static-site"
  name                = "st${var.project}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  site_dir            = "${path.root}/../site"
  tags                = local.common_tags
}

# Tell Terraform the resources moved address, so it does not destroy and recreate them
moved {
  from = azurerm_storage_account.site
  to   = module.static_site.azurerm_storage_account.this
}

moved {
  from = azurerm_storage_account_static_website.site
  to   = module.static_site.azurerm_storage_account_static_website.this
}

moved {
  from = azurerm_storage_blob.pages
  to   = module.static_site.azurerm_storage_blob.pages
}
