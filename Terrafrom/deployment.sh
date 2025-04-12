#!/bin/bash

set -e  # Exit on error
terraform init
terraform plan
terraform apply

