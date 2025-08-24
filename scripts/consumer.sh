#!/bin/bash

# Script Kafka Consumer with or without Group ID and SASL SCRAM authentication
# Usage: ./consumer.sh [topic_name] [group_name] [username] [password]
#        ./consumer.sh [topic_name] "" [username] [password]  # No group ID

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📥 Kafka Consumer${NC}"
echo "================"

# Get topic name
if [ -n "$1" ]; then
    TOPIC_NAME="$1"
    echo -e "${YELLOW}Topic:${NC} $TOPIC_NAME"
else
    echo -n "Enter topic name: "
    read TOPIC_NAME
fi

# Get group name
if [ -n "$2" ]; then
    GROUP_NAME="$2"
    echo -e "${YELLOW}Group:${NC} $GROUP_NAME"
else
    echo -n "Enter consumer group name (or press Enter for no group): "
    read GROUP_NAME
fi

# Get username
if [ -n "$3" ]; then
    USERNAME="$3"
    echo -e "${YELLOW}Username:${NC} $USERNAME"
else
    echo -n "Enter username: "
    read USERNAME
fi

# Get password
if [ -n "$4" ]; then
    PASSWORD="$4"
    echo -e "${YELLOW}Password:${NC} $PASSWORD"
else
    echo -n "Enter password: "
    read -s PASSWORD
    echo
fi

# Validate input
if [ -z "$TOPIC_NAME" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo -e "${RED}❌ Topic name, username and password cannot be empty${NC}"
    exit 1
fi

# Determine consumer type based on group name
if [ -z "$GROUP_NAME" ]; then
    echo -e "${GREEN}🚀 Starting consumer for topic '$TOPIC_NAME' (NO GROUP ID)${NC}"
    echo -e "${YELLOW}💡 Press Ctrl+C to exit${NC}"
    echo -e "${YELLOW}📡 Connecting to brokers: localhost:19093,localhost:29093,localhost:39093${NC}"
    echo -e "${YELLOW}🔄 Starting from beginning of topic${NC}"
    echo -e "${YELLOW}⚠️  Note: No group ID means no offset management${NC}"
    echo ""
    
    # Start consumer without group
    kafkacat \
        -C \
        -b localhost:19093,localhost:29093,localhost:39093 \
        -t "$TOPIC_NAME" \
        -o beginning \
        -X security.protocol=SASL_PLAINTEXT \
        -X sasl.mechanism=SCRAM-SHA-512 \
        -X sasl.username="$USERNAME" \
        -X sasl.password="$PASSWORD"
else
    echo -e "${GREEN}🚀 Starting consumer for topic '$TOPIC_NAME' with group '$GROUP_NAME'${NC}"
    echo -e "${YELLOW}💡 Press Ctrl+C to exit${NC}"
    echo -e "${YELLOW}📡 Connecting to brokers: localhost:19093,localhost:29093,localhost:39093${NC}"
    echo -e "${YELLOW}🔄 Starting from beginning of topic${NC}"
    echo -e "${YELLOW}✅ Group ID enabled for offset management${NC}"
    echo ""
    
    # Start consumer with group
    kafkacat \
        -C \
        -b localhost:19093,localhost:29093,localhost:39093 \
        -t "$TOPIC_NAME" \
        -G "$GROUP_NAME" \
        -o beginning \
        -X security.protocol=SASL_PLAINTEXT \
        -X sasl.mechanism=SCRAM-SHA-512 \
        -X sasl.username="$USERNAME" \
        -X sasl.password="$PASSWORD"
fi

echo -e "${GREEN}✅ Consumer stopped${NC}"
