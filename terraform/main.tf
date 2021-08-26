terraform {
    required_version = ">=0.12"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2.0"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "amdsysprov" {
    name = "amdSysProvGroup"
    location = "canadacentral"

    tags = {
        environment = "AMD SYSPROV"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "amdsysprov" {
    name                = "amdSysProvNet"
    address_space       = ["10.0.0.0/16"]
    location            = "canadacentral"
    resource_group_name = azurerm_resource_group.amdsysprov.name

    tags = {
        environment = "AMD SYSPROV"
    }
}

# Create subnet
resource "azurerm_subnet" "amdsysprov" {
    name                 = "amdSysProvSubnet"
    resource_group_name  = azurerm_resource_group.amdsysprov.name
    virtual_network_name = azurerm_virtual_network.amdsysprov.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "amdsysprov" {
    name                         = "amdSysProvPublicIP"
    location                     = "canadacentral"
    resource_group_name          = azurerm_resource_group.amdsysprov.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "AMD SYSPROV"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "amdsysprov" {
    name                = "amdSysProvNetworkSecurityGroup"
    location            = "canadacentral"
    resource_group_name = azurerm_resource_group.amdsysprov.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags = {
        environment = "AMD SYSPROV"
    }
}

# Create network interface
resource "azurerm_network_interface" "amdsysprov" {
    name                      = "amdSysProvNIC"
    location                  = "canadacentral"
    resource_group_name       = azurerm_resource_group.amdsysprov.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.amdsysprov.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.amdsysprov.id
    }

    tags = {
        environment = "AMD SYSPROV"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "secint" {
    network_interface_id      = azurerm_network_interface.amdsysprov.id
    network_security_group_id = azurerm_network_security_group.amdsysprov.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        resource_group = azurerm_resource_group.amdsysprov.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "amdsysprov" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.amdsysprov.name
    location                    = "canadacentral"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "AMD SYSPROV"
    }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "amdsysprov" {
    name                  = "amdSysProvVM"
    location              = "canadacentral"
    resource_group_name   = azurerm_resource_group.amdsysprov.name
    network_interface_ids = [azurerm_network_interface.amdsysprov.id]
    size                  = "Standard_B1s"

    os_disk {
        name              = "apache_hd"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "OpenLogic"
        offer     = "CentOS"
        sku       = "7.5"
        version   = "latest"
    }

    computer_name  = "web"
    admin_username = "zelezarof"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "zelezarof"
        public_key     = file("~/.ssh/id_rsa.pub")
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.amdsysprov.primary_blob_endpoint
    }

    tags = {
        environment = "AMD SYSPROV"
    }
}
