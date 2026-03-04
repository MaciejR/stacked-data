#!/usr/bin/env bash
# =========================================================
# Stacked Data — one-time Azure + GitHub setup script
# Edit the variables below, then run: bash setup.sh
# =========================================================
set -e

GITHUB_USER="MaciejR"
REPO_NAME="stacked-data"
REPO_DESCRIPTION="Stacked Data — Deep-dive technical articles on Microsoft Fabric and modern data engineering"
AZURE_RESOURCE_GROUP="rg-stacked-data"
AZURE_LOCATION="westeurope"
AZURE_SWA_NAME="stacked-data"
SITE_BASE_URL="https://kind-stone-05609a803.2.azurestaticapps.net/"

echo "==============================="
echo "  Stacked Data — Site Setup"
echo "==============================="
echo ""

echo "→ Initialising git repo"
git init
git add .
git commit -m "Initial scaffold: Stacked Data Hugo blog"

echo "→ Creating GitHub repo: $GITHUB_USER/$REPO_NAME"
gh repo create "$GITHUB_USER/$REPO_NAME" --public \
  --description "$REPO_DESCRIPTION" --source=. --remote=origin --push

echo "→ Creating Azure resource group: $AZURE_RESOURCE_GROUP"
az group create --name "$AZURE_RESOURCE_GROUP" --location "$AZURE_LOCATION" --output none

echo "→ Creating Azure Static Web App: $AZURE_SWA_NAME"
az staticwebapp create \
  --name "$AZURE_SWA_NAME" \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --location "$AZURE_LOCATION" \
  --source "https://github.com/$GITHUB_USER/$REPO_NAME" \
  --branch main \
  --app-location "/" \
  --output-location "public" \
  --login-with-github \
  --sku Free

echo "→ Fetching SWA deployment token"
SWA_TOKEN=$(az staticwebapp secrets list \
  --name "$AZURE_SWA_NAME" --resource-group "$AZURE_RESOURCE_GROUP" \
  --query "properties.apiKey" --output tsv)

echo "→ Setting GitHub secret: AZURE_STATIC_WEB_APPS_API_TOKEN"
gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN \
  --repo "$GITHUB_USER/$REPO_NAME" --body "$SWA_TOKEN"

echo "→ Getting SWA hostname"
SWA_HOSTNAME=$(az staticwebapp show \
  --name "$AZURE_SWA_NAME" --resource-group "$AZURE_RESOURCE_GROUP" \
  --query "defaultHostname" --output tsv)

FINAL_URL="https://$SWA_HOSTNAME"

echo "→ Setting GitHub variable: SITE_BASE_URL"
gh variable set SITE_BASE_URL \
  --repo "$GITHUB_USER/$REPO_NAME" --body "$FINAL_URL/"

echo ""
echo "==============================="
echo "  Done!"
echo "  GitHub : https://github.com/$GITHUB_USER/$REPO_NAME"
echo "  Live   : $FINAL_URL"
echo "==============================="
echo ""
echo "Next steps:"
echo "  1. Open $FINAL_URL — first deploy is already running via GitHub Actions"
echo "  2. To add a custom domain:"
echo "     az staticwebapp hostname set --name $AZURE_SWA_NAME --resource-group $AZURE_RESOURCE_GROUP --hostname your-domain.com"
