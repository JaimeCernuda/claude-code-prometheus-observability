#!/bin/bash

# Install Prometheus and related components on Ubuntu/Debian

set -e

echo "🚀 Installing Claude Code Prometheus Observability Stack on System..."

# Update package lists
echo "📦 Updating package lists..."
sudo apt-get update

# Install Prometheus
echo "📊 Installing Prometheus..."
sudo apt-get install -y prometheus

# Install Push Gateway
echo "📤 Installing Prometheus Push Gateway..."
sudo apt-get install -y prometheus-pushgateway

# Install Node Exporter
echo "📈 Installing Node Exporter..."
sudo apt-get install -y prometheus-node-exporter

# Install Grafana
echo "📈 Installing Grafana..."
sudo apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Copy configuration files
echo "⚙️ Configuring services..."

# Prometheus configuration
sudo cp ../prometheus.yml /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Create systemd service overrides if needed
sudo mkdir -p /etc/systemd/system/prometheus.service.d
sudo cat > /etc/systemd/system/prometheus.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.console.templates=/etc/prometheus/consoles \
    --storage.tsdb.retention.time=200h \
    --web.enable-lifecycle
EOF

# Enable and start services
echo "🔧 Enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl enable prometheus-pushgateway
sudo systemctl enable prometheus-node-exporter
sudo systemctl enable grafana-server

sudo systemctl start prometheus
sudo systemctl start prometheus-pushgateway
sudo systemctl start prometheus-node-exporter
sudo systemctl start grafana-server

echo "⏳ Waiting for services to start..."
sleep 10

echo "✅ Installation completed successfully!"
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
echo ""
echo "🔧 Service management:"
echo "  sudo systemctl {start|stop|restart|status} prometheus"
echo "  sudo systemctl {start|stop|restart|status} prometheus-pushgateway"
echo "  sudo systemctl {start|stop|restart|status} prometheus-node-exporter"
echo "  sudo systemctl {start|stop|restart|status} grafana-server"