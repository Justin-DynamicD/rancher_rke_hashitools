#===============================================================================
# Azure Data
#===============================================================================

data "azurerm_resource_group" "network_rg" {
  name = var.azure_network_resource_group
}

data "azurerm_subnet" "subnet" {
  name                 = var.azure_subnet_name
  virtual_network_name = var.azure_vnet_name
  resource_group_name  = data.azurerm_resource_group.network_rg.name
}

data "azurerm_image" "k8s" {
  name                = var.azure_image_name
  resource_group_name = var.azure_image_resource_group
}

#===============================================================================
# Azure Resource Group
#===============================================================================

resource "azurerm_resource_group" "main" {
  name     = var.azure_main_resource_group
  location = var.azure_location
}

#===============================================================================
# Azure Load Balancer
#===============================================================================

resource "azurerm_lb" "managerlb" {
  count               = var.add_manager_lb == "yes" ? "1" : "0"
  name                = "${azurerm_resource_group.main.name}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                          = "${azurerm_resource_group.main.name}-lb-ip"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    zones                         = var.azure_vm_availability_zones

  }
}

resource "azurerm_lb_backend_address_pool" "managerlbpool" {
  count               = var.add_manager_lb == "yes" ? "1" : "0"
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.managerlb.id
  name                = "${azurerm_resource_group.main.name}${var.vm_name_prefix}pool"
}

resource "azurerm_network_interface" "manager" {
  count                     = var.azure_vm_count
  name                      = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "manager" {
  count                   = var.add_manager_lb == "yes" ? "1" : "0"
  network_interface_id    = element(azurerm_network_interface.manager.*.id, count.index)
  ip_configuration_name   = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.managerlbpool.id
}

#===============================================================================
# Azure VMs
#===============================================================================

resource "azurerm_virtual_machine" "manager" {
  count                            = var.azure_vm_count
  name                             = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
  location                         = azurerm_resource_group.main.location
  zones                            = "${lookup(var.azure_vm_availability_zones, count.index)}"
  resource_group_name              = azurerm_resource_group.main.name
  network_interface_ids            = [element(azurerm_network_interface.manager.*.id, count.index)]
  vm_size                          = var.azure_vm_size
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = data.azurerm_image.k8s.id
  }

  storage_os_disk {
    name              = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
    admin_username = var.vm_user
    custom_data    = "#cloud-config\nhostname: ${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}\nfqdn: ${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}.${vm.domain}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = var.vm_ssh_key_path
      key_data = var.vm_ssh_public_key
    }
  }

  tags = merge(
    {
      "environmentinfo" = "T:Prod; N:${azurerm_resource_group.main.name}-${var.vm_name_prefix}-${count.index + 1}"
      "cluster"         = var.azure_main_resource_group
      "role"            = "manager"
    }
  )
}
