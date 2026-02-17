#!/bin/bash

# Azure Landing Zone Cleanup Script
# This script destroys all resources deployed by Terraform

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TENANT_ID="ac9ff574-a96d-4b6d-8811-15c5d145b220"
SUBSCRIPTION_ID="efb80fd1-010b-4344-86f0-55a423d10a1e"

echo -e "${RED}========================================${NC}"
echo -e "${RED}Azure Landing Zone Cleanup Script${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    exit 1
fi

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}Warning: No terraform.tfstate file found.${NC}"
    echo "There may be no resources to destroy, or they were deployed from a different location."
    read -p "Do you want to continue anyway? (yes/no): " CONTINUE
    if [ "$CONTINUE" != "yes" ]; then
        exit 0
    fi
fi

echo -e "${YELLOW}WARNING: This will destroy ALL resources created by this Terraform configuration!${NC}"
echo ""
echo "Resources that will be destroyed:"
echo "  - 4 Resource Groups"
echo "  - 3 Virtual Networks"
echo "  - 5 Subnets"
echo "  - 4 VNet Peerings"
echo "  - 3 Network Security Groups"
echo "  - 2 Route Tables"
echo "  - 1 Log Analytics Workspace"
echo ""
echo -e "${RED}This action CANNOT be undone!${NC}"
echo ""

read -p "Are you sure you want to destroy all resources? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${GREEN}Cleanup cancelled${NC}"
    exit 0
fi

echo ""
read -p "Type 'destroy' to confirm: " CONFIRM2

if [ "$CONFIRM2" != "destroy" ]; then
    echo -e "${GREEN}Cleanup cancelled${NC}"
    exit 0
fi

# Login to Azure
echo -e "${YELLOW}Logging in to Azure...${NC}"
az login --tenant $TENANT_ID

# Set subscription
echo -e "${YELLOW}Setting subscription...${NC}"
az account set --subscription $SUBSCRIPTION_ID

echo ""
echo -e "${RED}Destroying infrastructure...${NC}"
terraform destroy

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Terraform destroy failed${NC}"
    echo ""
    echo "You may need to manually delete resources in Azure Portal:"
    echo "https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cleanup Completed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "All resources have been destroyed."
echo "You can verify in Azure Portal that all resource groups are deleted:"
echo "https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
echo ""
