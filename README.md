# Claude Code Prometheus Observability

A comprehensive observability system for Claude Code that combines hooks-based event tracking with built-in OTEL metrics, all integrated with Prometheus for monitoring and visualization.

## Features

### 🔍 **Dual Data Sources**
- **Hooks System**: Real-time event tracking for tool usage, security, and sessions
- **OTEL Metrics**: Built-in metrics for costs, tokens, performance, and user prompts

### 📊 **Prometheus Integration**
- Convert hook events to Prometheus metrics
- Export OTEL metrics directly to Prometheus
- Unified metric collection and visualization

### 🛡️ **Security Features**
- Block dangerous `rm -rf` commands
- Prevent access to sensitive `.env` files
- Audit trail for all blocked operations

### 💰 **Cost & Performance Tracking**
- Token usage monitoring
- Cost per session/tool/user
- Performance bottleneck identification
- Response time analytics

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Claude Code    │    │   Hook System    │    │   Prometheus    │
│     Events      │───▶│  (Enhanced)      │───▶│    Metrics      │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   OTEL Built-in │    │   Prometheus     │    │    Grafana      │
│    Metrics      │───▶│    Exporter      │───▶│ Visualization   │
│                 │    │                  │    │                 │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Quick Start

### 1. Enable Claude Code Telemetry
```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=prometheus
export OTEL_LOG_USER_PROMPTS=1  # Optional: log user prompts
```

### 2. Deploy Prometheus (Docker)
```bash
docker run -d --name prometheus -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### 3. Deploy Prometheus (System)
```bash
# Ubuntu/Debian
sudo apt-get install prometheus
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

### 4. Configure Claude Code Hooks
Copy the `.claude` directory to your project and configure the hooks to send metrics to Prometheus instead of the custom HTTP endpoint.

## Configuration

### Environment Variables
- `CLAUDE_CODE_ENABLE_TELEMETRY=1` - Enable telemetry
- `OTEL_METRICS_EXPORTER=prometheus` - Export to Prometheus
- `OTEL_LOG_USER_PROMPTS=1` - Log user prompts (optional)
- `PROMETHEUS_PUSH_GATEWAY=http://localhost:9091` - Push Gateway URL

### Prometheus Configuration
See `prometheus.yml` for scraping configuration.

## Metrics

### Hook-based Metrics
- `claude_code_hook_events_total` - Total hook events by type
- `claude_code_tool_usage_total` - Tool usage counts
- `claude_code_security_blocks_total` - Security blocks by reason
- `claude_code_session_duration_seconds` - Session duration

### OTEL Metrics
- `claude_code_cost_usd` - Cost per session/model
- `claude_code_tokens_consumed` - Token usage
- `claude_code_response_time_seconds` - Response times
- `claude_code_active_sessions` - Active sessions

## Directory Structure
```
.claude/
├── settings.json              # Hook configuration
├── hooks/
│   ├── prometheus_sender.py   # Enhanced Prometheus sender
│   ├── pre_tool_use.py        # Security & logging
│   ├── post_tool_use.py       # Result tracking
│   ├── notification.py        # TTS notifications
│   └── utils/                 # Utilities
├── commands/                  # Custom commands
infrastructure/
├── docker/                    # Docker deployment
├── systemd/                   # System deployment
└── prometheus.yml             # Prometheus config
```

## Getting Started

1. **Clone the repository**
2. **Copy `.claude` directory to your project**
3. **Configure environment variables**
4. **Deploy Prometheus**
5. **Start using Claude Code with observability**

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details.