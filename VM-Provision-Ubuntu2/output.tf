output "public_ips" {
  value = [for pip in azurerm_public_ip.vm_pip : pip.ip_address]
}

output "private_ips" {
  value = [for nic in azurerm_network_interface.nic : nic.private_ip_address]
}

output "vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}