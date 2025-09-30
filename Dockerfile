# 1. Base Image: Use a full, stable Python 3.9 image on Debian 11 (Bullseye)
FROM python:3.9-bullseye

# 2. Install System Dependencies (Minimal but Complete for Wheel Linking)
# We need these packages for all other compiled dependencies (OpenCV, numpy, etc.)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Essential compilation tools
    build-essential \
    cmake \
    gfortran \
    python3-dev \
    # Libraries for OpenCV/image processing
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libatlas-base-dev \
    # Cleanup to reduce final image size
    && rm -rf /var/lib/apt/lists/*

# 3. Setup Application Directory
WORKDIR /app

# 4. CRITICAL FIX: Install Dlib using a pre-built wheel
# This avoids compiling Dlib from source, which is the source of the persistent exit code: 1 error.
# This specific wheel is built for Python 3.9 on Linux (manylinux_2_17 is standard)
RUN pip install --no-cache-dir https://github.com/conda-forge/dlib-feedstock/releases/download/v19.24/dlib-19.24.2-cp39-cp39-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

# 5. Install Remaining Python Dependencies
# We exclude dlib from the requirements.txt installation since it's already installed.
# We use a trick to install all remaining packages.
COPY requirements.txt /app/
RUN sed '/^dlib/d' requirements.txt > /tmp/requirements_rest.txt && \
    pip install --no-cache-dir -r /tmp/requirements_rest.txt

# 6. Copy Application Code
COPY . /app

# 7. Define Startup Command
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]