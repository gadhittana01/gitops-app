FROM httpd:2.4

# Install curl for health checks
RUN apt-get update && \
    CURL_VERSION=$(apt-cache policy curl | grep Candidate | awk '{print $2}') && \
    apt-get install -y --no-install-recommends curl=$CURL_VERSION && \
    rm -rf /var/lib/apt/lists/*

# Copy custom index.html
COPY index.html /usr/local/apache2/htdocs/index.html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
