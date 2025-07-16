# Claude Code Prometheus Observability System

A streamlined containerized Claude Code environment with Prometheus-based observability via hooks system.

## Features

### 🐳 **Containerized Environment**
- Claude Code running in Ubuntu 22.04 container
- Sudo access for full system control
- Persistent workspace folder for your files

### 📊 **Prometheus Observability**
- **Hook Events**: Real-time tool usage, security events, session tracking
- **Push Gateway**: Collects hook events and exposes to Prometheus
- **Grafana Dashboards**: Pre-configured visualization for Claude Code metrics

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

### Prometheus Hook Events
- **Tool Usage**: Real-time tracking of Read, Write, Bash, etc.
- **Security Events**: Blocks dangerous `rm -rf` commands and `.env` file access
- **Session Lifecycle**: Start, stop, duration tracking
- **Performance**: Tool execution timing and patterns
- **User Activity**: Session-based metrics and usage patterns

## Workspace

Your files are persisted in the `./workspace` directory, which is mounted to `/home/claude-user/workspace` in the container.

## Configuration

### Environment Variables
- `PROMETHEUS_PUSH_GATEWAY=http://pushgateway:9091` - Hook events target
- `USER_NAME` - Your name for tracking (required)
- `USER_EMAIL` - Your email for tracking (required)

### Observability Stack
- **Prometheus**: Scrapes Push Gateway for hook events
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

# Inside Claude Code container, your hooks are automatically active
# All tool usage is tracked to Prometheus via Push Gateway
# View dashboards at http://localhost:3000
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
                                                         │
                                                         │
                                                ┌──────────────────┐
                                                │     Grafana      │
                                                │ (Visualization)  │
                                                └──────────────────┘
```

This streamlined system provides excellent visibility into Claude Code usage patterns, tool usage, security events, and performance - all while maintaining the familiar `docker-compose run --rm claude-code` workflow.