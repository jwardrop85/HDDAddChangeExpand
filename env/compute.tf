
resource "azurerm_network_interface" "nic-hddtest-main-server2016" {
    name                = "nic-hddtest-main-server2016"
    location            = "${var.g-location}"
    resource_group_name = "${azurerm_resource_group.rg-main.name}"
    network_security_group_id = "${azurerm_network_security_group.nsg-hddtest-main.id}"

    ip_configuration {
        name                          = "ipcfg-hddtest-main"
        subnet_id                     = "${azurerm_subnet.snet-hddtest-main.id}"
        private_ip_address_allocation = "Dynamic"
    }

    tags {
        environment = "hddtest"
    }

    depends_on = ["azurerm_network_security_group.nsg-hddtest-main"]
}


resource "azurerm_virtual_machine" "vm-hddtest-server2016-prd" {
    name                  = "server2016-hddtest"
    location              = "${var.g-location}"
    resource_group_name   = "${azurerm_resource_group.rg-main.name}"
    network_interface_ids = ["${azurerm_network_interface.nic-hddtest-main-server2016.id}"]
    vm_size               = "${var.g-vmsize}"
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_os_disk {
        name              = "disk-hddtest-server2016-prd"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference  {
        publisher="MicrosoftWindowsServer"
        offer="WindowsServer"
        sku="2016-Datacenter"
        version="latest"
    }

    os_profile {
        computer_name  = "server2016-prd"
        admin_username = "azureadmin"
        admin_password = "${data.azurerm_key_vault_secret.adm-usr-server2016-prd.value}"
    }

    os_profile_windows_config {
        timezone = "GMT Standard Time"
        provision_vm_agent = "true"
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = "${azurerm_storage_account.stor-hddtest-main.primary_blob_endpoint}"
    }

    tags {
        environment = "hddtest"
    }

    depends_on = ["azurerm_storage_account.stor-hddtest-main","data.azurerm_key_vault_secret.adm-usr-server2016-prd"]
}

resource "azurerm_virtual_machine_extension" "InitVM" {
  name                 = "hostname"
  location             = "${var.g-location}"
  resource_group_name  = "${azurerm_resource_group.rg-main.name}"
  virtual_machine_name = "${azurerm_virtual_machine.vm-hddtest-server2016-prd.name}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  depends_on = ["azurerm_virtual_machine.vm-hddtest-server2016-prd" ]

  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/jwardrop85/HDDAddChangeExpand/dev/ps/Init-VM.ps1","https://raw.githubusercontent.com/jwardrop85/HDDAddChangeExpand/dev/ps/en-gb.xml","https://raw.githubusercontent.com/jwardrop85/HDDAddChangeExpand/dev/ps/default.reg"],
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File Init-VM.ps1"
    }
SETTINGS

  tags = {
    environment = "hddtest"
  }
}
