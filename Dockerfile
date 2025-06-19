FROM ghcr.io/open-webui/open-webui:main

# Set environment variables
ENV PORT=8080
ENV HOST=0.0.0.0
ENV OLLAMA_API_BASE_URL=http://ollama:11434
ENV WEBUI_AUTH=false
ENV WEBUI_DB=/data/webui.db

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# The entrypoint is already defined in the base image
