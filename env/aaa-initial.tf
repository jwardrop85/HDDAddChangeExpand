variable g-location {}
variable g-vmsize {}
variable g-sshkeydata {}
variable g-core-kv {}
variable g-core-rg {}

data "azurerm_key_vault" "kv-dev-core" {
  name                = "${var.g-core-kv}"
  resource_group_name = "${var.g-core-rg}"
}

data "azurerm_key_vault_secret" "adm-usr-server2016-prd" {
  name      = "adm-usr-server2016-prd"
  key_vault_id = "${data.azurerm_key_vault.kv-dev-core.id}"
  depends_on = ["data.azurerm_key_vault.kv-dev-core"]
}

data "azurerm_key_vault_secret" "sec-dsc-ep" {
  name      = "aa-dev-core-dsc-ep"
  key_vault_id = "${data.azurerm_key_vault.kv-dev-core.id}"
  depends_on = ["data.azurerm_key_vault.kv-dev-core"]
}

data "azurerm_key_vault_secret" "sec-dsc-pri-ak" {
  name      = "aa-dev-core-dsc-pri-ak"
  key_vault_id = "${data.azurerm_key_vault.kv-dev-core.id}"
  depends_on = ["data.azurerm_key_vault.kv-dev-core"]
}

resource "azurerm_resource_group" "rg-main" {
        name = "rg-hddtest-main"
        location = "${var.g-location}"

        tags {
            environment = "hddtest"
        }
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.rg-main.name}"
    }
    
    byte_length = 8

}

resource "azurerm_storage_account" "az-sa" {
    name                = "diag${random_id.randomId.hex}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    location            = "${var.g-location}"
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags {
        environment = "hddtest"
    }

    depends_on = ["azurerm_resource_group.rg-main"]
}
