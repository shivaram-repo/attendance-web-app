# --- STAGE 1: Build Stage (The ONLY stage that interacts with complex dependencies) ---
# We use a base image that already includes the necessary dlib/OpenCV headers.
FROM python:3.9-bullseye AS builder

# 1. Install Essential System Dependencies
# These are necessary for the dlib-bin wheel to link correctly at runtime.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    python3-dev \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt /app/

# 2. CRITICAL FIX: Install pre-compiled Dlib binary
# Use the 'dlib-bin' package to avoid compiling dlib, solving the memory error (used over 8GB).
# We install all dependencies here using the binary version of dlib.
# Note: face-recognition automatically handles dependencies like numpy and face-recognition-models.
RUN sed 's/^dlib==.*$/dlib-bin==19.24.2/' requirements.txt > /tmp/temp_requirements.txt && \
    pip install --no-cache-dir -r /tmp/temp_requirements.txt

# --- STAGE 2: Final Runtime Image (Smallest size for deployment) ---
# Start from a smaller, clean Python image for the final deployment.
FROM python:3.9-slim-bullseye

# 3. Install Runtime Dependencies (Minimal set for the final image)
# We only need system libraries required for face-recognition and opencv-python runtime.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# 4. Copy Code and Dependencies from the Builder Stage
WORKDIR /app
# Copy the entire Python environment (dependencies) from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
# Copy the application files
COPY . /app

# 5. Define Startup Command
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]