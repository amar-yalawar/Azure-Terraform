## Random suffix for unique names
resource "random_integer" "suffix" {
  count = var.vm_count
  min   = 1
  max   = 99
}

## Resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-${var.env}-rg"
  location = var.location

  tags = {
    project      = var.project
    environment  = var.env
    supported_by = var.supported_by
    owned_by     = var.owned_by
    service_class          = var.service_class
    managed_by   = var.managed_by
    status        = var.state
  }
}

## VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-${var.env}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = azurerm_resource_group.rg.tags
}

## Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.project}-${var.env}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

## NSG
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project}-${var.env}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ## Allow SSH
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

  # Allow HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.rg.tags
}

## Public IPs
resource "azurerm_public_ip" "vm_pip" {
  count               = var.vm_count
  name                = "${var.project}-${var.env}-pip-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.rg.tags
}

## Network Interfaces
resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "${var.project}-${var.env}-nic-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }

  tags = azurerm_resource_group.rg.tags
}

## Attach NSG to NICs
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

## Linux VMs
resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "${var.vm_base_name}${random_integer.suffix[count.index].result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id
  ]

  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  # Cloud-init: Format disk + install nginx + mysql on /data
  custom_data = base64encode(file("${path.module}/cloud-init-apps.yaml"))

  tags = azurerm_resource_group.rg.tags
}

## Extra Managed Disks
resource "azurerm_managed_disk" "data_disk" {
  count                = var.vm_count
  name                 = "${var.project}-${var.env}-datadisk-${count.index}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10

  tags = azurerm_resource_group.rg.tags
}

## Attach Disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[count.index].id
  lun                = 1
  caching            = "ReadWrite"
}