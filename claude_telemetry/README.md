# Claude Code Enhanced Telemetry System

A comprehensive containerized Claude Code environment with full observability via OpenTelemetry, Prometheus, and Grafana.

## Features

### 🐳 **Containerized Environment**
- Claude Code running in Ubuntu 22.04 container
- Sudo access for full system control
- Persistent workspace folder for your files
- Scientific MCPs pre-installed (ADIOS)

### 📊 **Dual Observability**
- **OTEL Built-in Metrics**: Cost, tokens, performance via OpenTelemetry Collector
- **Hooks Events**: Real-time tool usage, security events via Prometheus Push Gateway
- **Unified Visualization**: Both data sources in Grafana dashboards

### 🔧 **Infrastructure Stack**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Push Gateway**: Hook events collection
- **OTEL Collector**: Built-in telemetry processing

## Quick Start

### 1. Start the Observability Stack
```bash
cd claude_telemetry
docker-compose up -d prometheus grafana pushgateway otel-collector
```

### 2. Jump into Claude Code
```bash
docker-compose run --rm claude-code
```

That's it! Claude Code will start with full observability enabled.

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
- **OTEL Metrics**: http://localhost:8888/metrics

## Data Collection

### OTEL Built-in Metrics
- Session counts and duration
- Token consumption and costs
- Tool usage patterns
- Response times
- User prompt logging (if enabled)

### Hook Events
- Real-time tool execution
- Security blocks (dangerous commands)
- Session lifecycle events
- Error tracking
- Chat transcript collection

## Workspace

Your files are persisted in the `./workspace` directory, which is mounted to `/home/claude-user/workspace` in the container.

## Configuration

### Telemetry Settings
- `CLAUDE_CODE_ENABLE_TELEMETRY=1` - Enable telemetry
- `OTEL_LOG_USER_PROMPTS=1` - Log conversation content
- `OTEL_METRIC_EXPORT_INTERVAL=10000` - Export every 10 seconds
- `PROMETHEUS_PUSH_GATEWAY=http://pushgateway:9091` - Hook events target

### Observability Stack
- **Prometheus**: Scrapes OTEL metrics and Push Gateway
- **Grafana**: Pre-configured with Claude Code dashboard
- **OTEL Collector**: Exports to both file and Prometheus

## Workflow Example

```bash
# Start infrastructure
docker-compose up -d prometheus grafana pushgateway otel-collector

# Jump into Claude Code
export USER_NAME="John Doe"
export USER_EMAIL="john@example.com"
docker-compose run --rm claude-code

# Inside Claude Code container, your hooks are automatically active
# All tool usage is tracked to Prometheus
# All OTEL metrics flow to Prometheus
# View dashboards at http://localhost:3000
```

## Data Persistence

- **Prometheus data**: Stored in `prometheus_data` volume
- **Grafana data**: Stored in `grafana_data` volume  
- **Telemetry files**: Stored in `./telemetry-data/`
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
docker-compose logs otel-collector
docker-compose logs prometheus
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
│   Claude Code   │───▶│  OTEL Collector  │───▶│   Prometheus    │
│   (Container)   │    │  (OTLP → Prom)   │    │   (Storage)     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         │              ┌──────────────────┐            │
         └─────────────▶│  Push Gateway    │───────────┘
                        │  (Hook Events)   │
                        └──────────────────┘
                                 │
                        ┌──────────────────┐
                        │     Grafana      │
                        │ (Visualization)  │
                        └──────────────────┘
```

This system provides unprecedented visibility into Claude Code usage patterns, performance, costs, and behavior - all while maintaining the familiar `docker-compose run --rm claude-code` workflow.