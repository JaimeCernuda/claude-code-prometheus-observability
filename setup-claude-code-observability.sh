#!/bin/bash

# Setup script for Claude Code Prometheus Observability

set -e

echo "🚀 Setting up Claude Code Prometheus Observability..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Claude Code is installed
if ! command_exists claude-code; then
    echo "❌ Claude Code is not installed. Please install it first."
    exit 1
fi

echo "✅ Claude Code found"

# Set up environment variables
echo "⚙️ Setting up environment variables..."

# Create or update .env file
cat > .env << EOF
# Claude Code Observability Configuration
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=prometheus
OTEL_EXPORTER_PROMETHEUS_HOST=localhost
OTEL_EXPORTER_PROMETHEUS_PORT=8080
OTEL_LOG_USER_PROMPTS=1
PROMETHEUS_PUSH_GATEWAY=http://localhost:9091

# Optional: Engineer name for TTS notifications
ENGINEER_NAME=${USER}

# Optional: Logging configuration
CLAUDE_HOOKS_LOG_DIR=./logs
EOF

echo "✅ Environment configuration created in .env"

# Add to shell profile
SHELL_PROFILE=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ]; then
    echo ""
    echo "📝 Add these lines to your $SHELL_PROFILE:"
    echo "# Claude Code Observability"
    echo "export CLAUDE_CODE_ENABLE_TELEMETRY=1"
    echo "export OTEL_METRICS_EXPORTER=prometheus"
    echo "export OTEL_EXPORTER_PROMETHEUS_HOST=localhost"
    echo "export OTEL_EXPORTER_PROMETHEUS_PORT=8080"
    echo "export OTEL_LOG_USER_PROMPTS=1"
    echo "export PROMETHEUS_PUSH_GATEWAY=http://localhost:9091"
    echo ""
fi

# Copy .claude directory to current project
echo "📁 Setting up hooks for current project..."
if [ -d ".claude" ]; then
    echo "⚠️  .claude directory already exists. Backing up..."
    mv .claude .claude.backup.$(date +%Y%m%d_%H%M%S)
fi

cp -r .claude-template .claude
echo "✅ Claude Code hooks configured for this project"

# Choose deployment method
echo ""
echo "📦 Choose deployment method:"
echo "1. Docker (recommended)"
echo "2. System installation"
echo "3. Skip infrastructure setup"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "🐳 Setting up Docker infrastructure..."
        if ! command_exists docker; then
            echo "❌ Docker is not installed. Please install Docker first."
            exit 1
        fi
        
        cd infrastructure/docker
        chmod +x start.sh
        ./start.sh
        cd ../..
        ;;
    2)
        echo "🔧 Setting up system installation..."
        cd infrastructure/systemd
        chmod +x install.sh
        ./install.sh
        cd ../..
        ;;
    3)
        echo "⏭️  Skipping infrastructure setup"
        ;;
    *)
        echo "❌ Invalid choice. Skipping infrastructure setup."
        ;;
esac

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📊 Next steps:"
echo "1. Source your shell profile or restart your terminal"
echo "2. Navigate to your Claude Code project directory"
echo "3. Copy the .claude directory to your project"
echo "4. Start using Claude Code - metrics will be automatically collected"
echo ""
echo "🌐 Access your observability stack:"
echo "  - Prometheus: http://localhost:9090"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Push Gateway: http://localhost:9091"
echo ""
echo "📈 Metrics endpoints:"
echo "  - Hook events: http://localhost:9091/metrics"
echo "  - OTEL metrics: http://localhost:8080/metrics"