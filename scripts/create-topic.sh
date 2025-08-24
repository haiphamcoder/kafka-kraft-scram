#!/bin/bash

# Script to create Kafka topic
# Usage: ./create-topic.sh [topic_name] [partitions] [replication_factor]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📝 Kafka Topic Creator${NC}"
echo "========================"

# Get topic name
if [ -n "$1" ]; then
    TOPIC_NAME="$1"
    echo -e "${YELLOW}Topic name:${NC} $TOPIC_NAME"
else
    echo -n "Enter topic name: "
    read TOPIC_NAME
fi

# Get number of partitions
if [ -n "$2" ]; then
    PARTITIONS="$2"
    echo -e "${YELLOW}Partitions:${NC} $PARTITIONS"
else
    echo -n "Enter number of partitions: "
    read PARTITIONS
fi

# Get replication factor
if [ -n "$3" ]; then
    REPLICATION_FACTOR="$3"
    echo -e "${YELLOW}Replication factor:${NC} $REPLICATION_FACTOR"
else
    echo -n "Enter replication factor: "
    read REPLICATION_FACTOR
fi

# Validate input
if [ -z "$TOPIC_NAME" ]; then
    echo -e "${RED}❌ Topic name cannot be empty${NC}"
    exit 1
fi

if ! [[ "$PARTITIONS" =~ ^[0-9]+$ ]] || [ "$PARTITIONS" -lt 1 ]; then
    echo -e "${RED}❌ Partitions must be a positive integer${NC}"
    exit 1
fi

if ! [[ "$REPLICATION_FACTOR" =~ ^[0-9]+$ ]] || [ "$REPLICATION_FACTOR" -lt 1 ]; then
    echo -e "${RED}❌ Replication factor must be a positive integer${NC}"
    exit 1
fi

# Check if replication factor is valid for cluster size
if [ "$REPLICATION_FACTOR" -gt 3 ]; then
    echo -e "${YELLOW}⚠️  Warning: Replication factor ($REPLICATION_FACTOR) is greater than cluster size (3)${NC}"
    echo -e "${YELLOW}   This may cause issues. Continue? (y/N):${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Topic creation cancelled${NC}"
        exit 0
    fi
fi

echo -e "${YELLOW}⏳ Creating topic '$TOPIC_NAME' with $PARTITIONS partitions and replication factor $REPLICATION_FACTOR...${NC}"

# Create topic using kafka-topics
docker exec -it kafka-broker-1 kafka-topics \
    --bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
    --create \
    --topic "$TOPIC_NAME" \
    --partitions "$PARTITIONS" \
    --replication-factor "$REPLICATION_FACTOR"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Topic '$TOPIC_NAME' created successfully!${NC}"
    
    # Verify topic creation
    echo -e "${YELLOW}🔍 Verifying topic creation...${NC}"
    docker exec -it kafka-broker-1 kafka-topics \
        --bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
        --describe \
        --topic "$TOPIC_NAME"
else
    echo -e "${RED}❌ Failed to create topic '$TOPIC_NAME'${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Topic creation completed!${NC}"
echo -e "${BLUE}💡 You can now use this topic for producing and consuming messages${NC}"
