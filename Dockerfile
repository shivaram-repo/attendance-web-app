# 1. Base Image: Use the full, non-slim Debian 10 (Buster) image, which is very stable for dlib/OpenCV
FROM python:3.9-buster

# 2. Install System Dependencies (The Maximum, Guaranteed Fix)
# We use DEBIAN_FRONTEND=noninteractive to prevent interactive prompts during apt-get.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # The absolute essentials for C/C++ compilation
    build-essential \
    cmake \
    gfortran \
    python3-dev \
    # Libraries specifically required for dlib/OpenCV
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
    # OCR (for tesseract if face-recognition pulls it)
    libtesseract-dev \
    # Cleanup to save space
    && rm -rf /var/lib/apt/lists/*

# 3. Configure Environment Variables (Crucial for Dlib Compilation)
# These flags instruct dlib's build process to use specific optimization settings 
# and disable the GUI features that often cause failure.
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON

# 4. Setup Application Directory
WORKDIR /app

# 5. Copy and Install Python Dependencies
# We install numpy first to ensure its headers are available for dlib/opencv.
COPY requirements.txt /app/
RUN pip install --no-cache-dir numpy && \
    pip install --no-cache-dir -r requirements.txt

# 6. Copy Application Code
COPY . /app

# 7. Define Startup Command
# Using port 8000 for standard web deployment
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]