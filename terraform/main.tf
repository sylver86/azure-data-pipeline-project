# Definiamo la versione di Terraform e del provider Azure che useremo.
# Questa è una best practice per assicurare che il nostro codice funzioni
# anche in futuro senza sorprese.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configuriamo il provider Azure.
# Lasciando il blocco vuoto, diciamo a Terraform di usare le credenziali
# con cui abbiamo già fatto il login tramite Azure CLI (`az login`).
provider "azurerm" {
  features {}
}


# DEFINIZIONE DEL RESOURCE GROUP--------------------------------------------------------------------

# Definiamo le variabili che renderanno il nostro codice flessibile
variable "project_name" {
  description = "Il nome base per il nostro progetto."
  type        = string
  default     = "cinedata"
}

variable "location" {
  description = "La region di Azure dove verranno create le risorse."
  type        = string
  default     = "West Europe" # Usiamo una region più vicina
}

# Creiamo il Resource Group usando le variabili
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}" # Es. "rg-cinedata"
  location = var.location
}


# DEFINIZIONE DELLO STORAGE ACCOUNT ----------------------------------------------------------------


resource "random_string" "suffix"  {
    length = 6
    special = false
    upper = false
}


resource "azurerm_storage_account" "store_account" {
  name                     = "${var.project_name}${random_string.suffix.result}"                    # Associamo un nome randomico (in quanto deve esser univoco)
  resource_group_name      = azurerm_resource_group.rg.name                                         # Colleghiamo account storage al resource di prima.
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


# DEFINIZIONE DEL CONTAINER ------------------------------------------------------------------------


resource "azurerm_storage_container" "input" {
  name                  = "input"
  storage_account_name    = azurerm_storage_account.store_account.name                              # Aggancio allo storage account
  container_access_type = "private"
}



resource "azurerm_storage_container" "output" {
  name                  = "output"
  storage_account_name    = azurerm_storage_account.store_account.name                              # Aggancio allo storage account
  container_access_type = "private"
}



# DEFINIZIONE DELL'AZURE DATA FACTORY --------------------------------------------------------------

resource "azurerm_data_factory" "adf" {
  name                = "adf-${var.project_name}-${random_string.suffix.result}" # Nome unico
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name                                              # Aggancio al Resource group
}
