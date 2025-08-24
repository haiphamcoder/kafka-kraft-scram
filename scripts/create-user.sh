#!/bin/bash

# Script to create SCRAM user for Kafka
# Usage: ./create-user.sh [username] [password]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Kafka SCRAM User Creator${NC}"
echo "================================"

# Get username
if [ -n "$1" ]; then
    USERNAME="$1"
    echo -e "${YELLOW}Username:${NC} $USERNAME"
else
    echo -n "Enter username: "
    read USERNAME
fi

# Get password
if [ -n "$2" ]; then
    PASSWORD="$2"
    echo -e "${YELLOW}Password:${NC} $PASSWORD"
else
    echo -n "Enter password: "
    read -s PASSWORD
    echo
fi

# Validate input
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo -e "${RED}❌ Username and password cannot be empty${NC}"
    exit 1
fi

echo -e "${YELLOW}⏳ Creating SCRAM user '$USERNAME'...${NC}"

# Create user using kafka-configs
docker exec -it kafka-broker-1 kafka-configs \
    --bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
    --alter \
    --add-config "SCRAM-SHA-512=[password=$PASSWORD]" \
    --entity-type users \
    --entity-name "$USERNAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ SCRAM user '$USERNAME' created successfully!${NC}"
    
    # Verify user creation
    echo -e "${YELLOW}🔍 Verifying user creation...${NC}"
    docker exec -it kafka-broker-1 kafka-configs \
        --bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
        --describe \
        --entity-type users \
        --entity-name "$USERNAME"
else
    echo -e "${RED}❌ Failed to create user '$USERNAME'${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 User creation completed!${NC}"
echo -e "${BLUE}💡 You can now use this user for SASL authentication${NC}"
