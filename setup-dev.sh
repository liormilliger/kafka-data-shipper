#!/bin/bash
# This script installs dependencies and builds the project.
# It assumes it is being run from the root of the 'kafka-data-shipper' repo.

# Exit immediately if any command fails
set -e

COMPOSE_FILE="docker-compose.yaml" # Default compose file name

echo "--- 1. Updating packages and installing dependencies ---"
sudo apt-get update -y
sudo apt-get install -y maven git docker.io docker-compose

echo
echo "--- 2. Building 'common' artifact ---"
mvn install -f ./common-files/common

echo
echo "--- 3. Building 'producer' artifact (skipping tests) ---"
mvn install -f ./common-files/producer -DskipTests

echo
echo "--- 4. Building 'consumer' artifact (skipping tests) ---"
mvn install -f ./common-files/consumer -DskipTests

echo
echo "--- ✅ All builds complete. ---"
echo

echo "--- 5. Generating KRaft Cluster ID ---"
echo "Pulling Kafka image to generate Cluster ID..."
sudo docker pull confluentinc/cp-kafka:latest
echo "Generating Cluster ID..."
KAFKA_CLUSTER_ID=$(sudo docker run --rm confluentinc/cp-kafka:latest kafka-storage random-uuid)

if [ -z "$KAFKA_CLUSTER_ID" ]; then
    echo "❌ ERROR: Failed to generate Kafka Cluster ID. Exiting."
    exit 1
fi
echo "Successfully generated Cluster ID: $KAFKA_CLUSTER_ID"

echo
echo "--- 6. Updating $COMPOSE_FILE with Cluster ID ---"
# This assumes the placeholder is 'PASTE_YOUR_GENERATED_UUID_HERE'
# We use a different sed delimiter (%) because the ID might contain slashes (/)
sudo sed -i "s%CLUSTER_ID: 'PASTE_YOUR_GENERATED_UUID_HERE'%CLUSTER_ID: '$KAFKA_CLUSTER_ID'%" $COMPOSE_FILE

# Verify replacement
if ! grep -q "CLUSTER_ID: '$KAFKA_CLUSTER_ID'" $COMPOSE_FILE; then
    echo "❌ ERROR: Failed to update $COMPOSE_FILE with Cluster ID."
    echo "Please check the placeholder text in your YAML file."
    exit 1
fi
echo "Successfully updated $COMPOSE_FILE."
echo

echo "--- 7. Starting the entire application stack (MySQL & KRaft Kafka) ---"
sudo docker-compose up --build -d

echo
echo "--- ✅ Stack is launching in the background. ---"
echo "You can view logs with: sudo docker-compose logs -f"
echo "To trigger the producer, run:"
echo "curl -X POST http://localhost:9000/producer/?count=100"