#!/bin/bash

# Start Claude Code Prometheus Observability Stack

set -e

echo "🚀 Starting Claude Code Prometheus Observability Stack..."

# Create required directories
mkdir -p ./grafana/provisioning/{dashboards,datasources}

# Create Grafana datasource configuration
cat > ./grafana/provisioning/datasources/prometheus.yml << EOF
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: true
EOF

# Create Grafana dashboard configuration
cat > ./grafana/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Start services
echo "📦 Starting containers..."
docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "✅ Services started successfully!"
echo ""
echo "🌐 Access URLs:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Push Gateway: http://localhost:9091"
echo "  - Node Exporter: http://localhost:9100"
echo ""
echo "🔧 Configure Claude Code with:"
echo "  export CLAUDE_CODE_ENABLE_TELEMETRY=1"
echo "  export OTEL_METRICS_EXPORTER=prometheus"
echo "  export PROMETHEUS_PUSH_GATEWAY=http://localhost:9091"
echo ""
echo "📊 Hook metrics will be available at: http://localhost:9091/metrics"
echo "📈 OTEL metrics will be available at: http://localhost:8080/metrics"