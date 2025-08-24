# Kafka KRaft with SCRAM Authentication

A development and testing Docker Compose setup for Apache Kafka using KRaft (Kafka Raft) consensus protocol instead of ZooKeeper, with SASL/SCRAM authentication. This setup provides a solid foundation that can be enhanced for production use.

## 🚀 Overview

This project provides a complete, containerized Kafka cluster setup that eliminates the dependency on ZooKeeper by using KRaft mode. The cluster includes three Kafka brokers with built-in SCRAM authentication, making it suitable for development, testing, and learning purposes.

**Use Cases:**

- 🧪 **Development environments**
- 🧪 **Testing and QA**
- 📚 **Learning Kafka KRaft mode**
- 🚀 **Foundation for production setup** (with enhancements)

**Not Suitable For:**

- ❌ **Production environments** (without significant modifications)
- ❌ **High-security requirements**
- ❌ **Compliance-heavy industries**

**Key Features:**

- **KRaft Mode**: Modern consensus protocol replacing ZooKeeper
- **SASL/SCRAM Authentication**: Basic client authentication
- **Multi-Broker Cluster**: 3 brokers for high availability
- **Docker Compose**: Easy deployment and management
- **Development Ready**: Includes basic security and monitoring

## 📋 Prerequisites

Before running this project, ensure you have the following installed:

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Bash shell** (for running scripts)
- **kcat/kafkacat** (optional, for testing)

### System Requirements

- **Memory**: Minimum 4GB RAM
- **Storage**: At least 10GB free disk space
- **CPU**: 2+ cores recommended

## 🏗️ System Architecture

### KRaft Consensus Protocol

KRaft (Kafka Raft) is a consensus protocol that replaces ZooKeeper in Kafka clusters. It provides:

- **Controller Role**: Manages metadata and cluster coordination
- **Broker Role**: Handles data storage and client requests
- **Combined Mode**: Single process can act as both controller and broker
- **Improved Performance**: Lower latency and better scalability

### Cluster Architecture

The cluster consists of:

- **3 Kafka Brokers**: Each running in combined controller/broker mode
- **SASL/SCRAM Authentication**: Secure client connections
- **Docker Network**: Isolated container communication
- **User Management**: Handled through scripts and Makefile commands

### Security Model

- **SASL/SCRAM**: Challenge-response authentication mechanism
- **JAAS Configuration**: Java Authentication and Authorization Service
- **User Management**: Centralized user creation and management
- **Encrypted Communication**: TLS-ready configuration

## 🛠️ Setup and Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd kafka-kraft-scram
```

### 2. Generate Cluster ID

KRaft requires a unique cluster ID. Generate one using the provided script:

```bash
chmod +x scripts/generate-cluster-id.sh
./scripts/generate-cluster-id.sh
```

This will create a `CLUSTER_ID` file with a unique identifier.

### 3. Start the Cluster

```bash
# Start all services
make up

# Or use Docker Compose directly
docker compose up -d
```

### 4. Wait for Cluster Initialization

The cluster takes a few minutes to start up. Monitor the logs:

```bash
make logs
# Or
docker compose logs -f
```

**Note**: The cluster will start automatically without requiring an init service. All brokers run in combined controller/broker mode. User and topic management is handled through the provided shell scripts and Makefile commands.

### 5. Verify Cluster Status

```bash
make status
# Or
docker compose ps
```

## 🚀 Quick Start

### Using Makefile (Recommended)

```bash
# Complete setup in one command
make setup

# This will:
# 1. Create default SCRAM user (kafka/kafka)
# 2. Create test topic (test-topic) with 3 partitions and 3 replicas
```

### Manual Setup

```bash
# 1. Create SCRAM user
make create-default-user

# 2. Create test topic
make create-default-topic

# 3. Test producer
make producer-default

# 4. Test consumer (in another terminal)
make consumer-default
```

## 📖 Usage

### Scripts Overview

All scripts are located in the `scripts/` directory and support both interactive and command-line modes.

#### 1. User Management

**Create SCRAM User**:

```bash
# Interactive mode
./scripts/create-user.sh

# Command-line mode
./scripts/create-user.sh myuser mypassword
```

**Using Makefile**:

```bash
make create-user          # Interactive
make create-default-user  # Default user (kafka/kafka)
```

#### 2. Topic Management

**Create Topic**:

```bash
# Interactive mode
./scripts/create-topic.sh

# Command-line mode
./scripts/create-topic.sh my-topic 6 3
# Creates topic 'my-topic' with 6 partitions and 3 replicas
```

**Using Makefile**:

```bash
make create-topic          # Interactive
make create-default-topic  # Default topic (test-topic, 3 partitions, 3 replicas)
make list-topics           # List all topics
```

#### 3. Producer Operations

**Start Producer**:

```bash
# Interactive mode
./scripts/producer.sh

# Command-line mode
./scripts/producer.sh my-topic myuser mypassword
```

**Using Makefile**:

```bash
make producer              # Interactive
make producer-default      # Default topic (test-topic)
```

#### 4. Consumer Operations

**Start Consumer**:

```bash
# Interactive mode
./scripts/consumer.sh

# Command-line mode
./scripts/consumer.sh my-topic mygroup myuser mypassword
# For consumer without group ID (no offset management):
./scripts/consumer.sh my-topic "" myuser mypassword
```

**Using Makefile**:

```bash
make consumer              # Interactive with group
make consumer-default      # Default topic and group
```

### Makefile Commands

The project includes a comprehensive Makefile for easy management:

```bash
# Cluster Management
make up                    # Start cluster
make down                  # Stop cluster
make restart               # Restart cluster
make status                # Show container status
make logs                  # View logs

# Setup and Configuration
make setup                 # Complete initial setup
make create-default-user   # Create default SCRAM user
make create-default-topic  # Create default test topic

# Testing
make producer-default      # Start producer for test-topic
make consumer-default      # Start consumer for test-topic

# Cleanup
make clean                 # Remove containers and networks
make clean-volumes         # Remove Kafka data volumes (⚠️ DANGEROUS)
make clean-all             # Remove everything including images

# Monitoring
make health                # Check cluster health
make metrics               # Show broker metrics
make consumer-groups       # List consumer groups

# Help
make help                  # Show all available commands
```

## ⚙️ Configuration Details

### Docker Compose Configuration

The `docker-compose.yml` file defines:

- **3 Kafka Brokers**: Each running on different ports (19093, 29093, 39093)
- **KRaft Mode**: Combined controller/broker configuration
- **SASL/SCRAM**: Authentication mechanism configuration
- **Volume Mounts**: Persistent data storage and JAAS configuration
- **Network Configuration**: Internal and external listener setup

**Key Environment Variables:**

```yaml
KAFKA_PROCESS_ROLES: "broker,controller"
KAFKA_CONTROLLER_LISTENER_NAMES: "CONTROLLER"
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: "CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:SASL_PLAINTEXT"
KAFKA_SASL_MECHANISM_INTER_BROKER_PROTOCOL: "SCRAM-SHA-512"
```

### JAAS Configuration

The `kafka_server_jaas.conf` file configures SASL/SCRAM authentication:

```properties
KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};

Client {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};
```

**Configuration Details:**

- **KafkaServer**: Broker-side authentication configuration
- **Client**: Inter-broker communication authentication
- **SCRAM-SHA-512**: Strong cryptographic hash algorithm
- **Username/Password**: Admin credentials for cluster management

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. Cluster Startup Issues

**Problem**: Brokers fail to start with KRaft configuration errors

```bash
# Solution: Verify cluster ID
cat CLUSTER_ID
# Ensure CLUSTER_ID file exists and contains valid UUID
```

**Problem**: Authentication errors during startup

```bash
# Solution: Check JAAS configuration
docker exec -it kafka-broker-1 cat /etc/kafka/kafka_server_jaas.conf
```

#### 2. Authentication Issues

**Problem**: `SaslAuthenticationException: Authentication failed`

```bash
# Solution: Verify user exists
docker exec -it kafka-broker-1 kafka-configs \
  --bootstrap-server kafka-broker-1:9092 \
  --describe --entity-type users --entity-name kafka
```

**Problem**: Client cannot connect with SCRAM credentials

```bash
# Solution: Check client configuration
# Ensure security.protocol=SASL_PLAINTEXT
# Ensure sasl.mechanism=SCRAM-SHA-512
# Verify username/password match created user
```

#### 3. Network Connectivity

**Problem**: Clients cannot connect to external ports

```bash
# Solution: Verify port mapping
docker compose ps
# Check that ports 19093, 29093, 39093 are exposed
```

**Problem**: Internal broker communication issues

```bash
# Solution: Check internal listener configuration
docker exec -it kafka-broker-1 kafka-configs \
  --bootstrap-server kafka-broker-1:9092 \
  --describe --entity-type brokers --entity-name 1
```

#### 4. Performance Issues

**Problem**: Slow cluster startup

```bash
# Solution: Increase memory allocation
# Edit docker-compose.yml and increase memory limits
```

**Problem**: High memory usage

```bash
# Solution: Monitor resource usage
docker stats
# Adjust JVM heap settings if necessary
```

### Debug Commands

```bash
# Check broker logs
make logs

# Verify cluster health
make health

# Check consumer groups
make consumer-groups

# Inspect container configuration
make shell
```

## 📊 Monitoring and Health Checks

### Health Check Commands

```bash
# Basic health check
make health

# Detailed metrics
make metrics

# Consumer group status
make consumer-groups

# Container status
make status
```

### Log Monitoring

```bash
# Follow all logs
make logs

# Follow specific broker logs
docker compose logs -f kafka-broker-1
docker compose logs -f kafka-broker-2
docker compose logs -f kafka-broker-3
```

## 🚨 Production Readiness

### ⚠️ Current Status: Development/Testing Only

This setup is **NOT production-ready** as-is. It's designed for development, testing, and learning purposes. For production deployment, significant enhancements are required.

### 🔒 What's Missing for Production

**Security:**

- ❌ TLS/SSL encryption (currently plaintext)
- ❌ External secret management (hardcoded credentials)
- ❌ Access Control Lists (ACLs)
- ❌ Network segmentation and firewall rules

**Monitoring & Observability:**

- ❌ Prometheus metrics export
- ❌ Grafana dashboards
- ❌ Centralized logging (ELK stack)
- ❌ Alerting and notification system

**Operational:**

- ❌ Backup and restore procedures
- ❌ Disaster recovery plan
- ❌ Resource limits and quotas
- ❌ Rolling update procedures
- ❌ Performance tuning

**Compliance:**

- ❌ Audit logging
- ❌ Data retention policies
- ❌ Compliance monitoring

### 🎯 Production Enhancement Roadmap

1. **Phase 1: Security Hardening**
   - Enable TLS/SSL encryption
   - Implement external secret management
   - Add ACLs for topic access control

2. **Phase 2: Monitoring & Alerting**
   - Deploy Prometheus + Grafana
   - Setup centralized logging
   - Implement alerting rules

3. **Phase 3: Operational Excellence**
   - Backup automation
   - Performance tuning
   - Disaster recovery procedures

## 🔒 Security Considerations

### Current Security Status

⚠️ **Important**: This setup is designed for development and testing. For production use, significant security enhancements are required.

**Current Security Features:**

- Basic SASL/SCRAM authentication
- Hardcoded credentials (not suitable for production)
- No TLS/SSL encryption
- No access control lists (ACLs)

### Authentication Best Practices

1. **Strong Passwords**: Use complex passwords for production
2. **User Management**: Regularly audit user accounts
3. **Network Security**: Use TLS/SSL encryption in production
4. **Access Control**: Implement proper ACLs for topic access

### Production Security Requirements

```bash
# Enable TLS encryption
# Add to docker-compose.yml:
# KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: "CONTROLLER:PLAINTEXT,INTERNAL:PLAINTEXT,EXTERNAL:SASL_SSL"

# Use external secret management
# Mount secrets from Docker secrets or external vaults

# Implement ACLs
# kafka-acls --bootstrap-server localhost:9093 --add --allow-principal User:username --operation Read --topic topic-name
```

## 🧪 Testing

### Basic Functionality Test

```bash
# 1. Start cluster
make up

# 2. Wait for startup
sleep 60

# 3. Run complete test
make setup

# 4. Test producer/consumer
make producer-default
# In another terminal:
make consumer-default
```

### Advanced Testing

```bash
# Test multiple consumers with same group
make consumer-default
# In another terminal:
make consumer-default

# Test consumer without group
./scripts/consumer.sh test-topic "" kafka kafka

# Test custom topic
./scripts/create-topic.sh custom-topic 6 3
./scripts/producer.sh custom-topic kafka kafka
./scripts/consumer.sh custom-topic test-group kafka kafka
```

## 📚 Additional Resources

### Kafka Documentation

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [KRaft Mode Guide](https://kafka.apache.org/documentation/#kraft)
- [SASL/SCRAM Configuration](https://kafka.apache.org/documentation/#security_sasl_scram)

### Docker and Docker Compose

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

### Security

- [Kafka Security](https://kafka.apache.org/documentation/#security)
- [SASL Authentication](https://kafka.apache.org/documentation/#security_sasl)

## 🤝 Contributing

We welcome contributions to improve this project! Here's how you can help:

### Contributing Guidelines

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**: Follow the existing code style
4. **Test your changes**: Ensure the cluster starts and functions correctly
5. **Commit your changes**: Use clear, descriptive commit messages
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**: Provide detailed description of changes

### Development Setup

```bash
# Clone your fork
git clone https://github.com/haiphamcoder/kafka-kraft-scram.git
cd kafka-kraft-scram

# Create development branch
git checkout -b dev/your-feature

# Make changes and test
make up
make setup
# ... test your changes ...

# Commit and push
git add .
git commit -m "Add amazing feature"
git push origin dev/your-feature
```

### Code Style

- Follow existing shell script conventions
- Use meaningful variable names
- Add comments for complex logic
- Ensure scripts are executable (`chmod +x`)
- Test all changes before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apache Kafka community for the excellent documentation
- Docker team for containerization tools
- Contributors and users of this project

## 📞 Support

If you encounter issues or have questions:

1. **Check the troubleshooting section** above
2. **Review existing issues** in the repository
3. **Create a new issue** with detailed information
4. **Provide logs and error messages** for faster resolution

---

**Happy Kafka-ing! 🚀**:

*This README is maintained by the project contributors. For the latest updates, check the repository.*
