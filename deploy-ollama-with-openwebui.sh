#!/bin/bash

# Script to deploy Ollama with Open WebUI on AWS ECS Fargate

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
STACK_NAME="ollama-openwebui"
REGION="us-east-1"
PARAMETERS_FILE="ollama-openwebui-parameters.json"
TEMPLATE_FILE="ollama-with-openwebui.yaml"

# Function to display usage
usage() {
  echo -e "${YELLOW}Usage:${NC} $0 [options]"
  echo -e "  ${GREEN}-n, --name${NC}       Stack name (default: $STACK_NAME)"
  echo -e "  ${GREEN}-r, --region${NC}     AWS region (default: $REGION)"
  echo -e "  ${GREEN}-p, --parameters${NC} Parameters file (default: $PARAMETERS_FILE)"
  echo -e "  ${GREEN}-t, --template${NC}   CloudFormation template file (default: $TEMPLATE_FILE)"
  echo -e "  ${GREEN}-h, --help${NC}       Display this help message"
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -n|--name)
      STACK_NAME="$2"
      shift
      shift
      ;;
    -r|--region)
      REGION="$2"
      shift
      shift
      ;;
    -p|--parameters)
      PARAMETERS_FILE="$2"
      shift
      shift
      ;;
    -t|--template)
      TEMPLATE_FILE="$2"
      shift
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "${RED}Unknown option:${NC} $1"
      usage
      ;;
  esac
done

# Check if parameters file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
  echo -e "${RED}Error:${NC} Parameters file '$PARAMETERS_FILE' not found."
  exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
  echo -e "${RED}Error:${NC} Template file '$TEMPLATE_FILE' not found."
  exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo -e "${RED}Error:${NC} AWS CLI is not installed. Please install it first."
  exit 1
fi

echo -e "${GREEN}Deploying Ollama with Open WebUI...${NC}"
echo -e "${YELLOW}Stack Name:${NC} $STACK_NAME"
echo -e "${YELLOW}Region:${NC} $REGION"
echo -e "${YELLOW}Parameters File:${NC} $PARAMETERS_FILE"
echo -e "${YELLOW}Template File:${NC} $TEMPLATE_FILE"

# Check if stack exists
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
  echo -e "${YELLOW}Stack '$STACK_NAME' already exists. Updating...${NC}"
  
  # Update the stack
  aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters file://$PARAMETERS_FILE \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
  
  # Wait for stack update to complete
  echo -e "${YELLOW}Waiting for stack update to complete...${NC}"
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME --region $REGION
  
  echo -e "${GREEN}Stack update completed successfully!${NC}"
else
  echo -e "${YELLOW}Creating new stack '$STACK_NAME'...${NC}"
  
  # Create the stack
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$TEMPLATE_FILE \
    --parameters file://$PARAMETERS_FILE \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
  
  # Wait for stack creation to complete
  echo -e "${YELLOW}Waiting for stack creation to complete...${NC}"
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION
  
  echo -e "${GREEN}Stack creation completed successfully!${NC}"
fi

# Get stack outputs
echo -e "${GREEN}Stack Outputs:${NC}"
aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].Outputs" --output table

# Get the WebUI endpoint
WEBUI_ENDPOINT=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].Outputs[?OutputKey=='WebUIEndpoint'].OutputValue" --output text)
OLLAMA_ENDPOINT=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query "Stacks[0].Outputs[?OutputKey=='OllamaEndpoint'].OutputValue" --output text)

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}Open WebUI URL:${NC} $WEBUI_ENDPOINT"
echo -e "${YELLOW}Ollama API URL:${NC} $OLLAMA_ENDPOINT"
echo -e "${YELLOW}Note:${NC} It may take a few minutes for the services to start up and be accessible."
