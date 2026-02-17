#!/bin/bash

# Azure Landing Zone Deployment Script
# This script automates the deployment of the Azure Landing Zone

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TENANT_ID="ac9ff574-a96d-4b6d-8811-15c5d145b220"
SUBSCRIPTION_ID="efb80fd1-010b-4344-86f0-55a423d10a1e"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Azure Landing Zone Deployment Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed.${NC}"
    echo "Please install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Error: Terraform is not installed.${NC}"
    echo "Please install Terraform: https://www.terraform.io/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Azure CLI found${NC}"
echo -e "${GREEN}✓ Terraform found${NC}"
echo ""

# Login to Azure
echo -e "${YELLOW}Step 1: Logging in to Azure...${NC}"
az login --tenant $TENANT_ID

# Set subscription
echo -e "${YELLOW}Step 2: Setting subscription...${NC}"
az account set --subscription $SUBSCRIPTION_ID

# Verify subscription
CURRENT_SUB=$(az account show --query id -o tsv)
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
    echo -e "${RED}Error: Failed to set subscription${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Subscription set: $SUBSCRIPTION_ID${NC}"
echo ""

# Initialize Terraform
echo -e "${YELLOW}Step 3: Initializing Terraform...${NC}"
terraform init

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Terraform initialization failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform initialized${NC}"
echo ""

# Validate Terraform configuration
echo -e "${YELLOW}Step 4: Validating Terraform configuration...${NC}"
terraform validate

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Terraform validation failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform configuration valid${NC}"
echo ""

# Plan deployment
echo -e "${YELLOW}Step 5: Creating Terraform plan...${NC}"
terraform plan -out=tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Terraform planning failed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform plan created${NC}"
echo ""

# Confirm deployment
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Ready to deploy Azure Landing Zone${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "This will create the following resources:"
echo "  - 4 Resource Groups"
echo "  - 3 Virtual Networks (Hub + 2 Spokes)"
echo "  - 5 Subnets"
echo "  - 4 VNet Peerings"
echo "  - 3 Network Security Groups"
echo "  - 2 Route Tables"
echo "  - 1 Log Analytics Workspace"
echo ""
echo "Estimated monthly cost: \$0 (free tier)"
echo ""

read -p "Do you want to proceed with the deployment? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    rm -f tfplan
    exit 0
fi

# Apply Terraform
echo -e "${YELLOW}Step 6: Deploying infrastructure...${NC}"
terraform apply tfplan

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Terraform deployment failed${NC}"
    exit 1
fi

# Clean up plan file
rm -f tfplan

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Completed Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Show outputs
echo -e "${YELLOW}Deployment Outputs:${NC}"
terraform output

echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "1. Review the deployed resources in Azure Portal"
echo "2. Check the README.md for usage instructions"
echo "3. Review COST_ANALYSIS.md for cost monitoring tips"
echo "4. See ARCHITECTURE.md for detailed architecture documentation"
echo ""
echo -e "${YELLOW}To view this deployment in Azure Portal:${NC}"
echo "https://portal.azure.com/#view/HubsExtension/BrowseResourceGroups"
echo ""
echo -e "${YELLOW}To destroy this deployment later:${NC}"
echo "terraform destroy"
echo ""
