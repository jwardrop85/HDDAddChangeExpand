
resource "azurerm_virtual_network" "net-hddtest-main" {
    name                = "net-hddtest-main"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"

    tags {
        environment = "hddtest"
    }

    depends_on = ["azurerm_resource_group.rg-main"]
}

resource "azurerm_subnet" "snet-hddtest-main" {
    name                 = "snet-hddtest-main"
    resource_group_name  = "${azurerm_resource_group.rg-main.name}"
    virtual_network_name = "${azurerm_virtual_network.net-hddtest-main.name}"
    address_prefix       = "10.0.2.0/24"
    depends_on = ["azurerm_virtual_network.net-hddtest-main"]
}

resource "azurerm_network_security_group" "nsg-hddtest-main" {
    name                = "nsg-hddtest-main"
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    
    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "hddtest"
    }
}
