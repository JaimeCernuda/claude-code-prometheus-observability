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

# Copy export and init scripts
COPY export-telemetry.sh /usr/local/bin/
COPY init-hooks.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/export-telemetry.sh /usr/local/bin/init-hooks.sh

# Create claude-user with sudo privileges
RUN useradd -m -s /bin/bash claude-user && \
    echo "claude-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG sudo claude-user

# Switch to claude-user
USER claude-user
WORKDIR /home/claude-user

# Clone and install ADIOS MCP
RUN git clone https://github.com/iowarp/scientific-mcps.git && \
    cd scientific-mcps/Adios && \
    uv sync

# Create workspace directory
RUN mkdir -p /home/claude-user/workspace

# Switch to workspace and add MCP with correct command
WORKDIR /home/claude-user/workspace
RUN claude mcp add adios -- uv --directory /home/claude-user/scientific-mcps/Adios run adios-mcp

# Copy hooks template (will be mounted as volume in docker-compose)
RUN mkdir -p /home/claude-user/.claude-template

# Set environment variables for telemetry
ENV CLAUDE_CODE_ENABLE_TELEMETRY=1
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc

# Create entrypoint script
RUN echo '#!/bin/bash\n\
# Initialize hooks system\n\
/usr/local/bin/init-hooks.sh\n\
\n\
# Start Claude Code with dangerous mode\n\
exec claude --dangerously-skip-permissions "$@"' > /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]