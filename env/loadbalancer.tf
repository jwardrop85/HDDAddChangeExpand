#variable g-location {}
#variable g-core-kv {}
#variable g-core-rg {}


resource "azurerm_public_ip" "pubip-hddtest-main-lb" {
    name                         = "pubip-hddtest-main-lb"
    location                     = "${var.g-location}"
    resource_group_name          = "${azurerm_resource_group.rg-main.name}"
    allocation_method            = "Static"
    domain_name_label             = "a365-hdd-2016"
    tags {
        environment = "hddtest"
    }
}
resource "azurerm_lb" "lb-hddtest-main" {
  name                = "lb-hddtest-main"
  location            = "${var.g-location}"
  resource_group_name = "${azurerm_resource_group.rg-main.name}"

  frontend_ip_configuration {
    name                 = "lb-hddtest-main-fendip"
    public_ip_address_id = "${azurerm_public_ip.pubip-hddtest-main-lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lbbend-hddtest-main-server" {
  resource_group_name = "${azurerm_resource_group.rg-main.name}"
  loadbalancer_id     = "${azurerm_lb.lb-hddtest-main.id}"
  name                = "lbbend-hddtest-main-server"
}

resource "azurerm_lb_nat_rule" "nat-RDPAccess" {
  resource_group_name            = "${azurerm_resource_group.rg-main.name}"
  loadbalancer_id                = "${azurerm_lb.lb-hddtest-main.id}"
  name                           = "nat-RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 54523
  backend_port                   = 3389
  frontend_ip_configuration_name = "${azurerm_lb.lb-hddtest-main.frontend_ip_configuration.0.name}"
  depends_on = ["azurerm_lb.lb-hddtest-main"]
}

resource "azurerm_network_interface_backend_address_pool_association" "bend-link-hddtest-main-servernic-lb" {
  network_interface_id    = "${azurerm_network_interface.nic-hddtest-main-server2016.id}"
  ip_configuration_name   = "${azurerm_network_interface.nic-hddtest-main-server2016.ip_configuration.0.name}"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.lbbend-hddtest-main-server.id}"
  depends_on = ["azurerm_network_interface.nic-hddtest-main-server2016"]
}

resource "azurerm_network_interface_nat_rule_association" "nat-link-hddtest-main-servernic-lb" {
  network_interface_id  = "${azurerm_network_interface.nic-hddtest-main-server2016.id}"
  ip_configuration_name = "${azurerm_network_interface.nic-hddtest-main-server2016.ip_configuration.0.name}"
  nat_rule_id           = "${azurerm_lb_nat_rule.nat-RDPAccess.id}"
  depends_on = ["azurerm_network_interface.nic-hddtest-main-server2016","azurerm_lb_nat_rule.nat-RDPAccess"]
}