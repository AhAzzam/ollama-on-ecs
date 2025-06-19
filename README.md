# Ollama on ECS

Deploy Ollama (Large Language Model) on AWS ECS using CloudFormation.

## Overview

This repository contains infrastructure-as-code templates and scripts to deploy Ollama on Amazon ECS with Fargate, including:

- ECS Cluster with Fargate capacity providers
- Application Load Balancer for external access
- CloudWatch logging and monitoring
- Open WebUI integration for web interface

## Files

- `ollama-ecs-cluster.yaml` - Main CloudFormation template
- `ollama-ecs-parameters.json` - Parameters for deployment
- `deploy-ollama-cluster.sh` - Deployment script
- `validate-prerequisites.sh` - Prerequisites validation script
- `open-webui-task-def*.json` - Open WebUI task definitions
- `ollama-with-openwebui.yaml` - Combined Ollama + WebUI template

## Quick Start

1. Validate prerequisites:
   ```bash
   ./validate-prerequisites.sh
   ```

2. Deploy the stack:
   ```bash
   ./deploy-ollama-cluster.sh
   ```

3. Access Ollama via the Load Balancer URL provided in the output.

## Requirements

- AWS CLI configured
- Valid VPC, subnets, and security groups
- ECS task execution and task roles
- jq for JSON processing

## Architecture

- **ECS Cluster**: Fargate-based cluster with Container Insights
- **Load Balancer**: Application Load Balancer for HTTP access
- **Networking**: VPC with public subnets for Fargate tasks
- **Logging**: CloudWatch Logs with 7-day retention
- **Health Checks**: Container and ALB health checks

## Usage

Once deployed, you can interact with Ollama using its REST API or through the Open WebUI interface.