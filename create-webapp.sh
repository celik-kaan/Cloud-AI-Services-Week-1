#!/usr/bin/env bash
#
# Creates a resource group, an F1 (Free) Linux App Service plan and a web app
# using only Azure CLI commands.
#
# Usage:
#   ./create-webapp.sh [resource-group] [plan-name] [app-name] [location]
#
# Examples:
#   ./create-webapp.sh
#   ./create-webapp.sh rg-kaan-week1 plan-kaan-week1 kaan-webapp-week1-2026
#   ./create-webapp.sh rg-kaan-week1 plan-kaan-week1 kaan-webapp-week1-2026 switzerlandnorth

RESOURCE_GROUP="${1:-rg-webapp-week1}"
PLAN_NAME="${2:-plan-webapp-week1}"
# App names must be unique across all of Azure, so the default gets a random suffix.
APP_NAME="${3:-webapp-week1-$RANDOM$RANDOM}"
LOCATION="${4:-northeurope}"
SKU="F1"
RUNTIME="PYTHON:3.13"

# Stop the script with an error message if the previous command failed.
check() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1" >&2
        exit 1
    fi
}

echo "Resource group : $RESOURCE_GROUP"
echo "Plan           : $PLAN_NAME ($SKU, Linux)"
echo "Web app        : $APP_NAME ($RUNTIME)"
echo "Location       : $LOCATION"
echo

command -v az > /dev/null 2>&1
check "Azure CLI (az) is not installed or not on PATH."

az account show --output none
check "Not logged in to Azure. Run 'az login' first."

echo "Creating resource group '$RESOURCE_GROUP'..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none
check "Could not create resource group '$RESOURCE_GROUP'."

echo "Creating App Service plan '$PLAN_NAME'..."
az appservice plan create \
    --name "$PLAN_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku "$SKU" \
    --is-linux \
    --output none
check "Could not create App Service plan '$PLAN_NAME'."

echo "Creating web app '$APP_NAME'..."
az webapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$PLAN_NAME" \
    --runtime "$RUNTIME" \
    --output none
check "Could not create web app '$APP_NAME' (the name may already be taken)."

HOSTNAME=$(az webapp show \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query defaultHostName \
    --output tsv)
check "Could not read the hostname of web app '$APP_NAME'."

echo
echo "Done! Your web app is live at:"
echo "https://$HOSTNAME"
