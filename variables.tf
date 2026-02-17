variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "germanywestcentral"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Environment = "Test"
    ManagedBy   = "Terraform"
    Purpose     = "LandingZone"
    Framework   = "AzureWellArchitected"
  }
}

variable "hub_vnet_address_space" {
  description = "Address space for hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_workload_vnet_address_space" {
  description = "Address space for spoke workload VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "spoke_services_vnet_address_space" {
  description = "Address space for spoke services VNet"
  type        = list(string)
  default     = ["10.2.0.0/16"]
}

variable "hub_subnets" {
  description = "Subnets for hub VNet"
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
  }))
  default = {
    GatewaySubnet = {
      address_prefix    = "10.0.0.0/24"
      service_endpoints = []
    }
    AzureFirewallSubnet = {
      address_prefix    = "10.0.1.0/24"
      service_endpoints = []
    }
    ManagementSubnet = {
      address_prefix    = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
  }
}

variable "spoke_workload_subnets" {
  description = "Subnets for spoke workload VNet"
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
  }))
  default = {
    WorkloadSubnet = {
      address_prefix    = "10.1.0.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
  }
}

variable "spoke_services_subnets" {
  description = "Subnets for spoke services VNet"
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
  }))
  default = {
    ServicesSubnet = {
      address_prefix    = "10.2.0.0/24"
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}
