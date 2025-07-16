# Claude Code Prometheus Observability System

A streamlined containerized Claude Code environment with Prometheus-based observability via hooks system.

## Features

### 🐳 **Containerized Environment**
- Claude Code running in Ubuntu 22.04 container
- Sudo access for full system control
- Persistent workspace folder for your files

### 📊 **Dual Observability**
- **OTEL Built-in Metrics**: Cost, tokens, performance via Claude Code's built-in telemetry
- **Hook Events**: Real-time tool usage, security events, session tracking
- **Push Gateway**: Collects hook events and exposes to Prometheus
- **Grafana Dashboards**: Pre-configured visualization for both data sources

### 🔧 **Infrastructure Stack**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards  
- **Push Gateway**: Hook events collection

## Quick Start

### 1. Start the Observability Stack
```bash
cd claude_telemetry
docker-compose up -d prometheus grafana pushgateway
```

### 2. Jump into Claude Code
```bash
docker-compose run --rm claude-code
```

That's it! Claude Code will start with Prometheus observability enabled.

## Environment Variables

Set these before running:
```bash
export USER_NAME="Your Name"
export USER_EMAIL="your.email@example.com"
```

## Access Points

Once running, access the observability stack:

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Push Gateway**: http://localhost:9091

## Data Collection

### OTEL Built-in Metrics
- **Cost Tracking**: Token usage and costs per session/model
- **Performance**: Response times and processing metrics
- **Session Data**: Duration, activity patterns
- **User Prompts**: Full conversation logging (if enabled)

### Prometheus Hook Events
- **Tool Usage**: Real-time tracking of Read, Write, Bash, etc.
- **Security Events**: Blocks dangerous `rm -rf` commands and `.env` file access
- **Session Lifecycle**: Start, stop, duration tracking
- **Performance**: Tool execution timing and patterns

## Workspace

Your files are persisted in the `./workspace` directory, which is mounted to `/home/claude-user/workspace` in the container.

## Configuration

### Environment Variables
- `CLAUDE_CODE_ENABLE_TELEMETRY=1` - Enable built-in telemetry
- `OTEL_METRICS_EXPORTER=prometheus` - Export OTEL metrics to Prometheus format
- `OTEL_LOG_USER_PROMPTS=1` - Log user conversation content
- `PROMETHEUS_PUSH_GATEWAY=http://pushgateway:9091` - Hook events target
- `USER_NAME` - Your name for tracking (required)
- `USER_EMAIL` - Your email for tracking (required)

### Observability Stack
- **Prometheus**: Scrapes both OTEL metrics and Push Gateway
- **Grafana**: Pre-configured with Claude Code dashboard
- **Push Gateway**: Collects and exposes hook metrics

## Workflow Example

```bash
# Start infrastructure
docker-compose up -d prometheus grafana pushgateway

# Jump into Claude Code
export USER_NAME="John Doe"
export USER_EMAIL="john@example.com"
docker-compose run --rm claude-code

# Inside Claude Code container:
# - Hooks are automatically active (mapped as volume)
# - OTEL metrics export to Prometheus on port 8080
# - Hook events sent to Push Gateway
# - View dashboards at http://localhost:3000
```

## Data Persistence

- **Prometheus data**: Stored in `prometheus_data` volume
- **Grafana data**: Stored in `grafana_data` volume  
- **Workspace files**: Stored in `./workspace/`

## Security Features

The hooks system automatically blocks:
- Dangerous `rm -rf` commands
- Access to `.env` files with sensitive data
- Provides audit trail of all blocked operations

## Troubleshooting

### View logs
```bash
docker-compose logs claude-code
docker-compose logs prometheus
docker-compose logs pushgateway
```

### Reset data
```bash
docker-compose down -v  # Removes all volumes
```

### Manual hook setup
If hooks aren't working, manually copy them:
```bash
cp -r .claude-template /path/to/your/project/.claude
```

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Claude Code   │───▶│   Push Gateway   │───▶│   Prometheus    │
│   (Container)   │    │  (Hook Events)   │    │   (Storage)     │
│    + Hooks      │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         │              ┌──────────────────┐            │
         └─────────────▶│  OTEL Metrics    │───────────┘
                        │    (:8080)       │
                        └──────────────────┘
                                 │
                        ┌──────────────────┐
                        │     Grafana      │
                        │ (Visualization)  │
                        └──────────────────┘
```

This system provides comprehensive visibility into Claude Code with dual telemetry:
- **OTEL Built-in**: Costs, tokens, performance, user prompts
- **Hook Events**: Tool usage, security, session lifecycle

All while maintaining the familiar `docker-compose run --rm claude-code` workflow.