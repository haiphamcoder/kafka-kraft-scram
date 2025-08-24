#!/bin/bash

# Script Kafka Producer with SASL SCRAM authentication
# Usage: ./producer.sh [topic_name] [username] [password]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📤 Kafka Producer${NC}"
echo "================"

# Get topic name
if [ -n "$1" ]; then
    TOPIC_NAME="$1"
    echo -e "${YELLOW}Topic:${NC} $TOPIC_NAME"
else
    echo -n "Enter topic name: "
    read TOPIC_NAME
fi

# Get username
if [ -n "$2" ]; then
    USERNAME="$2"
    echo -e "${YELLOW}Username:${NC} $USERNAME"
else
    echo -n "Enter username: "
    read USERNAME
fi

# Get password
if [ -n "$3" ]; then
    PASSWORD="$3"
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

echo -e "${GREEN}🚀 Starting producer for topic '$TOPIC_NAME'${NC}"
echo -e "${YELLOW}💡 Type your messages and press Enter. Press Ctrl+C to exit.${NC}"
echo -e "${YELLOW}📡 Connecting to brokers: localhost:19093,localhost:29093,localhost:39093${NC}"
echo ""

# Check if kafkacat is installed
if ! command -v kafkacat &> /dev/null; then
    echo -e "${RED}❌ kafkacat is not installed${NC}"
    echo -e "${YELLOW}💡 Install kafkacat:${NC}"
    echo -e "${BLUE}   Ubuntu/Debian: sudo apt install kafkacat${NC}"
    echo -e "${BLUE}   macOS: brew install kafkacat${NC}"
    echo -e "${BLUE}   CentOS/RHEL: sudo yum install kafkacat${NC}"
    exit 1
fi

# Start producer
kafkacat \
    -P \
    -b localhost:19093,localhost:29093,localhost:39093 \
    -t "$TOPIC_NAME" \
    -X security.protocol=SASL_PLAINTEXT \
    -X sasl.mechanism=SCRAM-SHA-512 \
    -X sasl.username="$USERNAME" \
    -X sasl.password="$PASSWORD"

echo -e "${GREEN}✅ Producer stopped${NC}"
