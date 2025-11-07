# ---------- Stage 1: Builder ----------
FROM python:3.9-slim-bookworm as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip install --upgrade pip

# Install Cython and aimrocks first (required by setup.py)
RUN pip install --no-cache-dir "Cython==3.0.10" "aimrocks==0.5.*"

# Copy all source code (setup.py needs the full codebase)
COPY . .

# Install the aim package and its dependencies from setup.py
RUN pip install --no-cache-dir .

# ---------- Stage 2: Final runtime image ----------
FROM python:3.9-slim-bookworm

WORKDIR /app

# Install runtime dependencies only (no build tools needed)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy Python packages from builder (includes compiled Cython extensions and migrations)
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Migrations and other data files are included in the installed package via package_data
# No need to copy source code - it causes import conflicts

# Expose the desired port
EXPOSE 80

# Command to run your app
# --yes flag auto-initializes the Aim repository if it doesn't exist
CMD ["aim", "up", "--host", "0.0.0.0", "--port", "80", "--yes"]

