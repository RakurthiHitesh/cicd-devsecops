# ---- Build Stage ----
FROM python:3.11-slim AS builder

WORKDIR /app

# Install dependencies in a virtual environment
COPY app/requirements.txt .
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install -r requirements.txt

# ---- Final Stage ----
FROM python:3.11-slim

# Security: run as non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copy virtual env from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application source
COPY app/app.py .

# Use venv binaries
ENV PATH="/opt/venv/bin:$PATH"

# Switch to non-root user
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
