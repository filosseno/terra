
provider "azurerm" {
  skip_provider_registration = "true"
  features {
  }
}

resource "azurerm_resource_group" "group_demo" {
  name     = "group_demo"
  location = "italynorth"
}

resource "azurerm_virtual_network" "vn_demo" {
  name = "vn_demo"
  resource_group_name = azurerm_resource_group.group_demo.name
  location = azurerm_resource_group.group_demo.location
  address_space = ["10.0.0.0/16"]
}

resource "tls_private_key" "keys_demo" {
  algorithm = "RSA"
  rsa_bits = "4096"
  
}

#resource "azurerm_network_security_group" "sec_group_demo" {
 # name = "sec_group_demo"
  #resource_group_name = azurerm_resource_group.group_demo.name
  #location = azurerm_resource_group.group_demo.location

  #security_rule  {
   # name = "demo_1"
    #priority = "100"
    #direction = "Inbound"
    #access = "Allow"
    #protocol = "Tcp"
    #source_port_range = "*"
    #destination_port_range = "*"
    #source_address_prefixes = [ "0.0.0.0/0" ]

#  }
#}

#subnet1

resource "azurerm_subnet" "subnet_demo_1" {
  name = "subnet_demo_1"
  resource_group_name = azurerm_resource_group.group_demo.name
  virtual_network_name = azurerm_virtual_network.vn_demo.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "NIC_demo_1" {
  name = "NIC_demo"
  resource_group_name = azurerm_resource_group.group_demo.name
  location = azurerm_resource_group.group_demo.location
  
  ip_configuration {
    name = "configuration_demo"
    subnet_id = azurerm_subnet.subnet_demo_1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "VM_demo_1" {
  name = "VM_demo_1"
  resource_group_name = azurerm_resource_group.group_demo.name
  location = azurerm_resource_group.group_demo.location
  network_interface_ids = [azurerm_network_interface.NIC_demo_1.id]
  vm_size = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  

  storage_os_disk {
    name              = "OS_disk_demo_1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
    storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

    os_profile {
    computer_name  = "hostname1"
    admin_username = "demoadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    
    ssh_keys {
      path     = "/home/demoadmin/.ssh/authorized_keys"
      key_data = tls_private_key.keys_demo.public_key_openssh
    }
    }
  }


#subnet2 

resource "azurerm_subnet" "subnet_demo_2" {
  name = "subnet_demo_2"
  resource_group_name = azurerm_resource_group.group_demo.name
  virtual_network_name = azurerm_virtual_network.vn_demo.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NIC_demo_2" {
  name = "NIC_demo_2"
  resource_group_name = azurerm_resource_group.group_demo.name
  location = azurerm_resource_group.group_demo.location

  ip_configuration {
    name = "config_demo"
    subnet_id = azurerm_subnet.subnet_demo_2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "VM_demo_2" {
  name = "VM_demo_2"
  resource_group_name = azurerm_resource_group.group_demo.name
  location = azurerm_resource_group.group_demo.location
  network_interface_ids = [azurerm_network_interface.NIC_demo_2.id]
  vm_size = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "OS_disk_demo_2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
    storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

    os_profile {
    computer_name  = "hostname2"
    admin_username = "demoadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/demoadmin/.ssh/authorized_keys"
      key_data = tls_private_key.keys_demo.public_key_openssh
    }
  }
}

output "private_key_pem" {
  value     = tls_private_key.keys_demo.private_key_pem
  sensitive = true
}