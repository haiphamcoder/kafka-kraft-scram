# Kafka KRaft SCRAM Cluster Makefile
# Usage: make <target>

.PHONY: help up down restart logs status clean clean-volumes clean-kafka-volumes clean-all-volumes clean-all setup create-default-user create-user create-default-topic create-topic list-topics producer-default producer consumer-default consumer clean-logs clean-configs

# Default target
help:
	@echo "🚀 Kafka KRaft SCRAM Cluster Management"
	@echo ""
	@echo "📋 Available commands:"
	@echo "  up                    - Start Kafka cluster"
	@echo "  down                  - Stop Kafka cluster"
	@echo "  restart               - Restart Kafka cluster"
	@echo "  logs                  - Show logs from all services"
	@echo "  status                - Show status of all containers"
	@echo ""
	@echo "🔧 Setup & Configuration:"
	@echo "  setup                 - Initial setup (create user, topic)"
	@echo "  create-default-user   - Create default SCRAM user (kafka/kafka)"
	@echo "  create-user           - Create SCRAM user interactively"
	@echo "  create-default-topic  - Create test topic (test-topic) with 3 partitions and 3 replicas"
	@echo "  create-topic          - Create topic interactively"
	@echo "  list-topics           - List all topics"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  producer-default      - Start producer for test-topic"
	@echo "  producer              - Start producer interactively"
	@echo "  consumer-default      - Start consumer for test-topic with test-group"
	@echo "  consumer              - Start consumer interactively with group"
	@echo ""
	@echo "🧹 Cleanup:"
	@echo "  clean                 - Remove containers and networks"
	@echo "  clean-volumes         - Remove Kafka data volumes (⚠️ DANGEROUS)"
	@echo "  clean-all-volumes     - Remove ALL Docker volumes (⚠️ VERY DANGEROUS)"
	@echo "  clean-all             - Remove everything including images"
	@echo "  clean-logs            - Clean container logs"
	@echo "  clean-configs         - Clean configuration files"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  health                - Check cluster health"
	@echo "  metrics               - Show broker metrics"
	@echo "  consumer-groups       - List consumer groups"

# Docker Compose commands
up:
	@echo "🚀 Starting Kafka cluster..."
	docker compose up -d
	@echo "⏳ Waiting for cluster to be ready..."
	@sleep 10
	@echo "✅ Kafka cluster started!"

down:
	@echo "🛑 Stopping Kafka cluster..."
	docker compose down
	@echo "✅ Kafka cluster stopped!"

restart:
	@echo "🔄 Restarting Kafka cluster..."
	docker compose restart
	@echo "✅ Kafka cluster restarted!"

# Logs and status
logs:
	@echo "📋 Showing logs from all services..."
	docker compose logs -f

status:
	@echo "📊 Container status:"
	docker compose ps
	@echo ""
	@echo "🔍 Detailed status:"
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Setup and configuration
setup: create-default-user create-default-topic
	@echo "✅ Setup completed!"

create-default-user:
	@echo "🔐 Creating default SCRAM user (kafka/kafka)..."
	@./scripts/create-user.sh kafka kafka || echo "User may already exist"
	@echo "✅ Default SCRAM user created!"

create-default-topic:
	@echo "📝 Creating test topic with default settings..."
	@./scripts/create-topic.sh test-topic 3 3 || echo "Topic may already exist"
	@echo "✅ Test topic created!"

create-user:
	@echo "🔐 Creating SCRAM user interactively..."
	@./scripts/create-user.sh

create-topic:
	@echo "📝 Creating topic interactively..."
	@./scripts/create-topic.sh

list-topics:
	@echo "📋 Listing all topics:"
	@docker exec -it kafka-broker-1 kafka-topics \
		--bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
		--list

# Testing
producer-default:
	@echo "📤 Starting producer for test-topic..."
	@./scripts/producer.sh test-topic kafka kafka

consumer-default:
	@echo "📥 Starting consumer for test-topic with group 'test-group'..."
	@./scripts/consumer.sh test-topic test-group kafka kafka

producer:
	@echo "📤 Starting producer interactively..."
	@./scripts/producer.sh

consumer:
	@echo "📥 Starting consumer interactively..."
	@./scripts/consumer.sh

# Cleanup commands
clean:
	@echo "🧹 Cleaning up containers and networks..."
	docker compose down --remove-orphans
	@echo "✅ Cleanup completed!"

clean-volumes:
	@echo "⚠️  WARNING: This will delete ALL Kafka data!"
	@echo "⚠️  Are you sure? Type 'yes' to continue:"
	@read -p "> " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "🗑️  Removing Kafka data volumes..."
	docker compose down -v
	@echo "✅ Kafka data volumes removed!"

clean-all-volumes:
	@echo "⚠️  WARNING: This will delete ALL Docker volumes on your system!"
	@echo "⚠️  Are you sure? Type 'yes' to continue:"
	@read -p "> " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "🗑️  Removing all Docker volumes..."
	docker volume prune -f
	@echo "✅ All Docker volumes removed!"

clean-all:
	@echo "⚠️  WARNING: This will delete EVERYTHING including images!"
	@echo "⚠️  Are you sure? Type 'yes' to continue:"
	@read -p "> " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "🗑️  Removing everything..."
	docker compose down -v --rmi all
	docker system prune -af
	@echo "✅ Everything cleaned!"

clean-logs:
	@echo "🧹 Cleaning container logs..."
	docker system prune -f
	@echo "✅ Logs cleaned!"

clean-configs:
	@echo "🧹 Cleaning configuration files..."
	rm -f client.properties kafkacat.conf
	@echo "✅ Configuration files cleaned!"

# Monitoring
health:
	@echo "🏥 Checking cluster health..."
	@echo "1. Checking broker connectivity..."
	@docker exec -it kafka-broker-1 kafka-broker-api-versions \
		--bootstrap-server kafka-broker-1:9092 > /dev/null && echo "✅ Broker 1: OK" || echo "❌ Broker 1: FAILED"
	@docker exec -it kafka-broker-2 kafka-broker-api-versions \
		--bootstrap-server kafka-broker-2:9092 > /dev/null && echo "✅ Broker 2: OK" || echo "❌ Broker 2: FAILED"
	@docker exec -it kafka-broker-3 kafka-broker-api-versions \
		--bootstrap-server kafka-broker-3:9092 > /dev/null && echo "✅ Broker 3: OK" || echo "❌ Broker 3: FAILED"
	@echo ""
	@echo "2. Checking topics..."
	@make list-topics
	@echo ""
	@echo "3. Checking users..."
	@docker exec -it kafka-broker-1 kafka-configs \
		--bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
		--describe \
		--entity-type users 2>/dev/null || echo "❌ No users found"

metrics:
	@echo "📊 Broker metrics:"
	@echo "Broker 1:"
	@docker exec -it kafka-broker-1 kafka-configs \
		--bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
		--describe \
		--entity-type brokers \
		--entity-name 1 2>/dev/null || echo "❌ Cannot retrieve metrics"

consumer-groups:
	@echo "👥 Consumer groups:"
	@docker exec -it kafka-broker-1 kafka-consumer-groups \
		--bootstrap-server kafka-broker-1:9092,kafka-broker-2:9092,kafka-broker-3:9092 \
		--list 2>/dev/null || echo "❌ No consumer groups found"

# Utility commands
shell:
	@echo "🐚 Opening shell to kafka-broker-1..."
	docker exec -it kafka-broker-1 bash

