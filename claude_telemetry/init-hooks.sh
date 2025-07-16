#!/bin/bash

# Initialize Claude Code hooks system for observability

set -e

echo "🔧 Initializing Claude Code observability hooks..."

# Check if hooks template exists
if [ ! -d "/home/claude-user/.claude-template" ]; then
    echo "❌ .claude-template directory not found!"
    exit 1
fi

# Copy hooks template to current project if not exists
if [ ! -d "/home/claude-user/workspace/.claude" ]; then
    echo "📁 Setting up hooks for workspace..."
    cp -r /home/claude-user/.claude-template /home/claude-user/workspace/.claude
    echo "✅ Hooks configured successfully"
else
    echo "ℹ️  Hooks already configured"
fi

# Set up environment variables
echo "⚙️ Environment configuration:"
echo "  CLAUDE_CODE_ENABLE_TELEMETRY=1"
echo "  OTEL_METRICS_EXPORTER=otlp"
echo "  PROMETHEUS_PUSH_GATEWAY=$PROMETHEUS_PUSH_GATEWAY"

echo ""
echo "🌐 Observability stack available at:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Push Gateway: http://localhost:9091"
echo "  - OTEL Collector: http://localhost:8888/metrics"
echo ""
echo "📊 Starting Claude Code with full observability..."
echo ""