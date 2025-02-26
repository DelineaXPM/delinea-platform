#!/bin/bash

# In order to run the script the user should have the following permissions:
# storage.buckets.create

export BUCKET_NAME=<Replace me: Bucket name>
export PROJECT=<Replace me: ProjectId>
export SERVICE_ACCOUNT_NAME=<Replace me: Service account name>
export CREATE_KEY=true

CONFIG_FILE=$1
# Function to check if required variables are set
check_required_vars() {
    if [[ -f $CONFIG_FILE ]]; then
        echo "Config file is found file found. Sourcing..."
        source $CONFIG_FILE
    fi

    if [ -z "${PROJECT:-}" ]; then
        echo "Error: PROJECT environment variables is not set."
        exit 1
    fi
    if [ -z "${BUCKET_NAME:-}" ]; then
        echo "Error: BUCKET_NAME environment variables is not set."
        exit 1
    fi
    if [ -z "${SERVICE_ACCOUNT_NAME:-}" ]; then
        echo "Error: SERVICE_ACCOUNT_NAME environment variables is not set."
        exit 1
    fi
    ORGANIZATION=$(gcloud projects describe $PROJECT --format="value(parent.id)")
    echo "Organization is $ORGANIZATION"
    echo "Project ID is $PROJECT"
    echo "Bucket name is $BUCKET_NAME"
    echo "Service account is $SERVICE_ACCOUNT_NAME"
    echo "Create key for Service account is $CREATE_KEY"
}

create_bucket() {
    FULL_BUCKET_NAME="gs://${BUCKET_NAME}__${ORGANIZATION}"
    echo "Full bucket name: $FULL_BUCKET_NAME"

    # Check if the bucket exists
    if gcloud storage buckets describe --project="$PROJECT" "$FULL_BUCKET_NAME" > /dev/null 2>&1; then
            echo "Bucket $FULL_BUCKET_NAME already exists."
    else
            echo "Bucket $FULL_BUCKET_NAME does not exist. Creating..."
            if gcloud storage buckets create --project="$PROJECT" --retention-period=3d "$FULL_BUCKET_NAME"; then
                echo "Bucket $FULL_BUCKET_NAME created successfully."
            else
                echo "Error: Failed to create bucket $FULL_BUCKET_NAME."
                exit 1
            fi
    fi
    lifecycle_file=$(mktemp)
    trap "rm -f '$lifecycle_file'" EXIT
    LIFECYCLE_RULE='{"rule":[{"action":{"type":"Delete"},"condition":{"age": 4 }}]}'
    echo $LIFECYCLE_RULE > $lifecycle_file
    gcloud storage buckets update $FULL_BUCKET_NAME --lifecycle-file=$lifecycle_file
}

enable_api() {
    # Check if the Cloud Asset API is already enabled
    API=$1

    if gcloud services list --enabled --project="$PROJECT" | grep -q "$API"; then
            echo "$API is already enabled."
    else
            echo "$API is not enabled. Enabling..."
            if gcloud services enable --project="$PROJECT" $API; then
                echo "$API enabled successfully."
            else
                echo "Error: Failed to enable Cloud Asset API."
                exit 1
            fi
    fi
}

enable_apis() {
    # Check if the Cloud Asset API is already enabled
    APIS=("cloudasset.googleapis.com" "cloudresourcemanager.googleapis.com" "logging.googleapis.com" "admin.googleapis.com" "iam.googleapis.com")

    for api in "${APIS[@]}"; do
        enable_api "$api"
    done
}

create_service_account() {
    SERVICE_ACCOUNT_MAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT}.iam.gserviceaccount.com"
    KEY_FILE_PATH="/tmp/$SERVICE_ACCOUNT_NAME.key.$$"

    create_key=$CREATE_KEY
    # Check if the service account exists
    if gcloud iam service-accounts list --project "$PROJECT" --format="value(email)" | grep -q $SERVICE_ACCOUNT_MAIL; then
        echo "Service account '${SERVICE_ACCOUNT_NAME}' already exists."
    else
        # Create the service account
        gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
            --description="Service account for ${SERVICE_ACCOUNT_NAME}" \
            --display-name="${SERVICE_ACCOUNT_NAME}" \
            --project="$PROJECT"

        echo "Service account '${SERVICE_ACCOUNT_NAME}' created."
        create_key=true
    fi

    if [ "$create_key" = true ]; then
        if gcloud iam service-accounts keys create "$KEY_FILE_PATH" \
            --iam-account="$SERVICE_ACCOUNT_MAIL" \
            --project="$PROJECT"; then
            echo "Key file for service account '${SERVICE_ACCOUNT_NAME}' created at '${KEY_FILE_PATH}'."
            cat $KEY_FILE_PATH
        fi
    fi

    # Define roles to assign
    ROLES=("roles/cloudasset.viewer" "roles/storage.objectAdmin" "roles/logging.viewer" "roles/serviceusage.serviceUsageAdmin")

    # Assign roles to the service account if not already assigned
    all_policies=$(gcloud organizations get-iam-policy "$ORGANIZATION" --format="json(bindings)")
    for ROLE in "${ROLES[@]}"; do
        echo "Assigning role $ROLE to service account $SERVICE_ACCOUNT_MAIL"
        existing_policy=$(echo $all_policies | jq --arg role "$ROLE" '.bindings[] | select(.role == $role)' | grep -q "$SERVICE_ACCOUNT_MAIL")
        echo "Found existing policy for service account $existing_policy"
        if [ -z "${existing_policy}" ]; then
            gcloud organizations add-iam-policy-binding "$ORGANIZATION" \
                --member="serviceAccount:${SERVICE_ACCOUNT_MAIL}" \
                --role="$ROLE"

            echo "Assigned role '${ROLE}' to service account '${SERVICE_ACCOUNT_NAME}'."
        else
            echo "Role '${ROLE}' is already assigned to service account '${SERVICE_ACCOUNT_NAME}'."
        fi
    done

    echo "Setting roles for viewing bucket"
    BUCKET_ROLE="roles/storage.admin"
    all_policies=$(gcloud storage buckets get-iam-policy "$FULL_BUCKET_NAME" --format="json(bindings)")
    existing_bucket_policy=$(echo $all_policies | jq --arg role "$BUCKET_ROLE" '.bindings[] | select(.role == $role)' | grep "$SERVICE_ACCOUNT_MAIL")
    echo "Found existing policy for service account on bucket $existing_policy"
    if [ -z "${existing_bucket_policy}" ]; then
        gcloud storage buckets add-iam-policy-binding "$FULL_BUCKET_NAME" \
            --member="serviceAccount:${SERVICE_ACCOUNT_MAIL}" \
            --role="$BUCKET_ROLE"

        echo "Assigned role '${BUCKET_ROLE}' to bucket '${FULL_BUCKET_NAME}'."
    else
        echo "Role '${BUCKET_ROLE}' is already assigned to bucket '${FULL_BUCKET_NAME}'."
    fi
}

# Validate required environment variables after sourcing .env file
check_required_vars
create_bucket
enable_apis
create_service_account


