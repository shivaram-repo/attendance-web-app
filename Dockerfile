# 1. Base Image: Use the current stable base for Python 3.9 (Debian 11: Bullseye)
# This fixes the apt-get 404/exit code 100 error.
FROM python:3.9-bullseye

# 2. Install System Dependencies (The Maximum, Guaranteed Fix for Dlib/OpenCV)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # The absolute essentials for C/C++ compilation
    build-essential \
    cmake \
    gfortran \
    python3-dev \
    # Libraries specifically required for dlib/OpenCV math operations
    libopenblas-dev \
    liblapack-dev \
    libhdf5-dev \
    libssl-dev \
    # Image I/O libraries
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # X11/GUI libraries (needed for linking, even if GUI is disabled)
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    # OCR (if needed by face-recognition)
    libtesseract-dev \
    # Cleanup to save space
    && rm -rf /var/lib/apt/lists/*

# 3. Configure Environment Variables (Crucial for Dlib Compilation)
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON

# 4. Setup Application Directory
WORKDIR /app

# 5. Copy and Install Python Dependencies (Separated for Dlib/NumPy stability)
COPY requirements.txt /app/
# Install numpy first, then the rest. This is the most reliable pip installation method.
RUN pip install --no-cache-dir numpy && \
    pip install --no-cache-dir -r requirements.txt

# 6. Copy Application Code
COPY . /app

# 7. Define Startup Command
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]