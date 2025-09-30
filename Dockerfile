# 1. Base Image: Use a full, stable Python 3.9 image on Debian 11 (Bullseye)
FROM python:3.9-bullseye

# 2. Install System Dependencies (The Comprehensive List)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Essential compilation tools
    build-essential \
    cmake \
    gfortran \
    python3-dev \
    # Libraries for dlib/OpenCV image processing (JPEG, PNG, TIFF)
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # Libraries for display/GUI support (even if disabled, sometimes required for linking)
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    # Optimized BLAS/LAPACK for NumPy/dlib speed (CRITICAL)
    libatlas-base-dev \
    # Tesseract (if needed for any dependencies like OCR)
    libtesseract-dev \
    # Cleanup to reduce final image size
    && rm -rf /var/lib/apt/lists/*

# 3. Configure Environment Variables
# Essential flags for dlib compilation
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON

# 4. Setup Application Directory
WORKDIR /app

# 5. Copy and Install Dependencies (Sequential Fix for Dlib)
COPY requirements.txt /app/

# Install dependencies in two stages to guarantee NumPy is available for dlib
RUN pip install --no-cache-dir numpy && \
    pip install --no-cache-dir -r requirements.txt

# 6. Copy Application Code and Define Startup Command
COPY . /app

# The application uses Flask with gunicorn on port 8000
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]