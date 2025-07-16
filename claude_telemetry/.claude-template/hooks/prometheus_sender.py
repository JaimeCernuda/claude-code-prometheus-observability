#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "prometheus-client",
#     "anthropic",
#     "python-dotenv",
# ]
# ///

"""
Prometheus Observability Hook Script
Sends Claude Code hook events to Prometheus via Push Gateway or exposes metrics endpoint.
"""

import json
import sys
import os
import argparse
import time
from datetime import datetime
from prometheus_client import Counter, Histogram, Gauge, CollectorRegistry, push_to_gateway
from prometheus_client.gateway import default_handler
from utils.summarizer import generate_event_summary

# Create a custom registry for this script
registry = CollectorRegistry()

# Define Prometheus metrics
hook_events_total = Counter(
    'claude_code_hook_events_total',
    'Total number of Claude Code hook events',
    ['source_app', 'session_id', 'event_type', 'tool_name'],
    registry=registry
)

tool_usage_total = Counter(
    'claude_code_tool_usage_total',
    'Total tool usage count',
    ['tool_name', 'session_id', 'source_app'],
    registry=registry
)

security_blocks_total = Counter(
    'claude_code_security_blocks_total',
    'Total security blocks by reason',
    ['reason', 'session_id', 'source_app'],
    registry=registry
)

session_duration_histogram = Histogram(
    'claude_code_session_duration_seconds',
    'Session duration in seconds',
    ['session_id', 'source_app'],
    registry=registry
)

active_sessions = Gauge(
    'claude_code_active_sessions',
    'Number of active Claude Code sessions',
    ['source_app'],
    registry=registry
)

def sanitize_label_value(value):
    """Sanitize label values for Prometheus"""
    if value is None:
        return "unknown"
    return str(value).replace('"', '\\"')

def extract_tool_name(event_data):
    """Extract tool name from event data"""
    payload = event_data.get('payload', {})
    return payload.get('tool_name', 'unknown')

def detect_security_block(event_data):
    """Detect if this is a security block event"""
    payload = event_data.get('payload', {})
    tool_input = payload.get('tool_input', {})
    
    # Check for dangerous rm commands
    if payload.get('tool_name') == 'Bash':
        command = tool_input.get('command', '')
        if 'rm' in command.lower() and ('-rf' in command or '-fr' in command):
            return 'dangerous_rm_command'
    
    # Check for .env file access
    if 'file_path' in tool_input:
        file_path = tool_input['file_path']
        if '.env' in file_path and not file_path.endswith('.env.sample'):
            return 'env_file_access'
    
    return None

def send_metrics_to_prometheus(event_data, gateway_url='http://localhost:9091'):
    """Send metrics to Prometheus Push Gateway"""
    try:
        source_app = sanitize_label_value(event_data.get('source_app', 'unknown'))
        session_id = sanitize_label_value(event_data.get('session_id', 'unknown'))
        event_type = sanitize_label_value(event_data.get('hook_event_type', 'unknown'))
        tool_name = sanitize_label_value(extract_tool_name(event_data))
        
        # Increment hook events counter
        hook_events_total.labels(
            source_app=source_app,
            session_id=session_id,
            event_type=event_type,
            tool_name=tool_name
        ).inc()
        
        # Increment tool usage counter for tool events
        if event_type in ['PreToolUse', 'PostToolUse'] and tool_name != 'unknown':
            tool_usage_total.labels(
                tool_name=tool_name,
                session_id=session_id,
                source_app=source_app
            ).inc()
        
        # Check for security blocks
        security_reason = detect_security_block(event_data)
        if security_reason:
            security_blocks_total.labels(
                reason=security_reason,
                session_id=session_id,
                source_app=source_app
            ).inc()
        
        # Track session activity
        if event_type == 'Stop':
            # Session ended, we could calculate duration here if we had start time
            pass
        
        # Update active sessions gauge (simplified - just track current activity)
        active_sessions.labels(source_app=source_app).set(1)
        
        # Push metrics to gateway
        push_to_gateway(
            gateway_url,
            job='claude-code-hooks',
            registry=registry,
            handler=default_handler
        )
        
        return True
        
    except Exception as e:
        print(f"Failed to send metrics to Prometheus: {e}", file=sys.stderr)
        return False

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Send Claude Code hook events to Prometheus')
    parser.add_argument('--source-app', required=True, help='Source application name')
    parser.add_argument('--event-type', required=True, help='Hook event type (PreToolUse, PostToolUse, etc.)')
    parser.add_argument('--gateway-url', default='http://localhost:9091', help='Prometheus Push Gateway URL')
    parser.add_argument('--add-chat', action='store_true', help='Include chat transcript if available')
    parser.add_argument('--summarize', action='store_true', help='Generate AI summary of the event')
    
    args = parser.parse_args()
    
    try:
        # Read hook data from stdin
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Prepare event data for Prometheus
    event_data = {
        'source_app': args.source_app,
        'session_id': input_data.get('session_id', 'unknown'),
        'hook_event_type': args.event_type,
        'payload': input_data,
        'timestamp': int(datetime.now().timestamp() * 1000)
    }
    
    # Handle --add-chat option
    if args.add_chat and 'transcript_path' in input_data:
        transcript_path = input_data['transcript_path']
        if os.path.exists(transcript_path):
            # Read .jsonl file and convert to JSON array
            chat_data = []
            try:
                with open(transcript_path, 'r') as f:
                    for line in f:
                        line = line.strip()
                        if line:
                            try:
                                chat_data.append(json.loads(line))
                            except json.JSONDecodeError:
                                pass  # Skip invalid lines
                
                # Add chat to event data
                event_data['chat'] = chat_data
            except Exception as e:
                print(f"Failed to read transcript: {e}", file=sys.stderr)
    
    # Generate summary if requested
    if args.summarize:
        summary = generate_event_summary(event_data)
        if summary:
            event_data['summary'] = summary
        # Continue even if summary generation fails
    
    # Send to Prometheus
    success = send_metrics_to_prometheus(event_data, args.gateway_url)
    
    # Always exit with 0 to not block Claude Code operations
    sys.exit(0)

if __name__ == '__main__':
    main()