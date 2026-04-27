FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
WORKDIR /app

# Copy dependency files first for layer caching — deps only reinstall when these change
COPY pyproject.toml README.md ./
RUN uv sync --no-cache --no-install-project

# Copy application code and entrypoint
COPY gsc_server.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# For Cloudflare Containers: streamable-http transport, bind to all interfaces
ENV MCP_TRANSPORT=streamable-http
ENV MCP_HOST=0.0.0.0
ENV MCP_PORT=3001

EXPOSE 3001

# Entrypoint handles credential injection from Cloudflare Secrets at startup
ENTRYPOINT ["./entrypoint.sh"]
