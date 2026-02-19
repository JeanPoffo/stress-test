<h3 align="center">Stress Test - Virtual Threads vs Coroutines</h3>

<div align="center">

[![Status](https://img.shields.io/badge/version-1.0-blue)]()
[![Status](https://img.shields.io/badge/status-active-green)]()
[![Java](https://img.shields.io/badge/Java-21-orange)]()
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.25-purple)]()

</div>

---

<p align="center">
  Performance comparison between Java Virtual Threads and Kotlin Coroutines using Spring Boot
</p>

## Table of Contents

- [About](#about)
- [How it works](#working)
- [Usage](#usage)
- [Getting Started](#getting_started)
- [Built Using](#built_using)

## About <a name = "about"></a>

This project provides a comprehensive stress test to compare the performance characteristics of Java Virtual Threads versus Kotlin Coroutines in a Spring Boot environment. Both implementations expose the same REST API endpoints and use PostgreSQL databases, allowing for direct performance comparison under identical load conditions.

The project includes two separate Spring Boot applications:
- **with-coroutine**: Implementation using Kotlin Coroutines for asynchronous operations
- **with-virtual-thread**: Implementation using Java 21 Virtual Threads for concurrent processing

Each application is containerized with Docker and includes k6 for load testing, enabling automated performance benchmarking.

## How it works <a name = "working"></a>

The project consists of two identical Spring Boot applications that differ only in their concurrency model:

### Architecture

Both applications follow the same clean architecture pattern:
- **Controller Layer**: REST API endpoints for car management
- **Use Case Layer**: Business logic implementation
- **Repository Layer**: Database access using Spring Data JPA
- **PostgreSQL Database**: Each implementation has its own isolated database

### Key Differences

**Coroutine Implementation**:
- Uses `suspend` functions for non-blocking operations
- Leverages Kotlin Coroutines for asynchronous processing
- Runtime: Spring Boot with Undertow server

**Virtual Thread Implementation**:
- Uses standard blocking calls on Virtual Threads
- Leverages Java 21's Virtual Threads (`-Dspring.threads.virtual.enabled=true`)
- Runtime: Spring Boot with Undertow server

### Load Testing

The project includes k6 load testing configured to run 50,000 requests against each implementation, with real-time dashboard monitoring available at `http://localhost:5665`.

## Usage <a name = "usage"></a>

All commands are available through the Makefile:

```bash
# Build both projects
make build

# Build individual projects
make build-coroutine
make build-virtual-thread

# Start all services (databases + applications)
make run

# Stop all services
make stop

# View logs
make logs                    # All services
make logs-coroutine          # Coroutine app only
make logs-virtual-thread     # Virtual thread app only

# Run load test with live dashboard
make load-test

# Monitor resource usage (CPU, memory)
make monitor-resources

# Check service status
make status

# Clean up containers and volumes
make clean

# Full rebuild and restart
make rebuild
```

### API Endpoints

Both applications expose the same endpoints:

- **Coroutine app**: `http://localhost:8080`
- **Virtual Thread app**: `http://localhost:8081`

Example endpoint: `GET /cars` - Retrieve all cars from the database

## 🏁 Getting Started <a name = "getting_started"></a>

### Prerequisites

```
Docker & Docker Compose
Java 21 (for local development)
Kotlin 1.9.25
Gradle 8.x
```

### Running the Project

1. Clone the repository:
```bash
git clone <repository-url>
cd stress-test
```

2. Build the Docker images:
```bash
make build
```

3. Start all services:
```bash
make run
```

4. Run the load test:
```bash
make load-test
```

The applications will be available at:
- Coroutine implementation: http://localhost:8080
- Virtual Thread implementation: http://localhost:8081
- k6 Dashboard (during load test): http://localhost:5665

### Resource Limits

Both applications are configured with identical resource constraints:
- CPU: 0.5 cores (max)
- Memory: 250MB (max)
- JVM Heap: -Xmx200m -Xms128m

This ensures fair comparison between the two concurrency models.

## Built Using <a name = "built_using"></a>

- **[Kotlin](https://kotlinlang.org/)** - Programming language
- **[Spring Boot 3.4.4](https://spring.io/projects/spring-boot)** - Application framework
- **[Java 21](https://openjdk.org/projects/jdk/21/)** - JVM and Virtual Threads support
- **[PostgreSQL 14](https://www.postgresql.org/)** - Database
- **[Docker](https://www.docker.com/)** - Containerization
- **[k6](https://k6.io/)** - Load testing tool
- **[Undertow](https://undertow.io/)** - Web server

Key dependencies:
- Spring Data JPA
- Kotlin Coroutines (core, reactive, reactor)
- Jackson for JSON processing