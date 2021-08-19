variable "artifactslocation" {
  description = "Location of WVD Artifacts" 
  default = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration.zip"
}

variable "hpoolname" {
  description = "The name of the host pool as it shows in Azure"
  type = string
}

resource "azurerm_virtual_machine_extension" "registersessionhost" {
  name                 = "registersessionhost"
  virtual_machine_id   = element(azurerm_virtual_machine.vm.*.id, count.index)
  publisher            = "Microsoft.Powershell"
  depends_on           = ["azurerm_virtual_machine_extension.domainjoinext"]
  count                = "${var.vm_count}"
  type = "DSC"
  type_handler_version = "2.73"
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
        "ModulesUrl": "${var.artifactslocation}",
        "ConfigurationFunction" : "Configuration.ps1\\AddSessionHost",
        "Properties": {
            "hostPoolName": "${var.hpoolname}",
            "registrationInfoToken": "${azurerm_virtual_desktop_host_pool.wvdhppooled.registration_info[0].token}"
        }
    }
SETTINGS
