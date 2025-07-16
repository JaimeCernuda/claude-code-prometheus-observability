FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    build-essential \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 18+ (required for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install uv (Python package manager) and prometheus client
RUN pip3 install uv prometheus-client

# Install Claude Code as root (needs global permissions)
RUN npm install -g @anthropic-ai/claude-code

# No additional scripts needed

# Create claude-user with sudo privileges
RUN useradd -m -s /bin/bash claude-user && \
    echo "claude-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG sudo claude-user

# Switch to claude-user
USER claude-user
WORKDIR /home/claude-user

# Create workspace directory
RUN mkdir -p /home/claude-user/workspace

# Switch to workspace
WORKDIR /home/claude-user/workspace

# Set environment variables for monitoring
ENV CLAUDE_CODE_ENABLE_TELEMETRY=1
ENV OTEL_METRICS_EXPORTER=prometheus
ENV PROMETHEUS_PUSH_GATEWAY=http://pushgateway:9091

# Set Claude as the entrypoint with dangerous mode
ENTRYPOINT ["claude", "--dangerously-skip-permissions"]