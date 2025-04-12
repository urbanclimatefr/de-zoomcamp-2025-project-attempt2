#!/bin/bash

# To replicate, define the path to your GCP service account key
GCP_KEY_PATH="$HOME/.gc/my-creds.json"

# Export GOOGLE_APPLICATION_CREDENTIALS
export GOOGLE_APPLICATION_CREDENTIALS="$GCP_KEY_PATH"

# Authentication
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"

# Verification
gcloud auth list