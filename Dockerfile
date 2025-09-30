# 1. Base Image: Use Python 3.9 based on Debian 11 (Bullseye)
FROM python:3.9-bullseye

# 2. Install System Dependencies (CRITICAL STEP for dlib/face-recognition/opencv)
# This command installs the necessary compilation tools and image libraries.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Essential compilation tools
    build-essential \
    cmake \
    gfortran \
    # Libraries for dlib/OpenCV image processing
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libatlas-base-dev \
    libtesseract-dev \
    # Cleanup to reduce final image size
    && rm -rf /var/lib/apt/lists/*

# 3. Configure Environment Variables
# DLIB_NO_GUI_SUPPORT speeds up compilation by disabling GUI features
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON

# 4. Setup Application Directory
WORKDIR /app
COPY . /app

# 5. Install Python Dependencies
# This step will now succeed because the system dependencies are satisfied
RUN pip install --no-cache-dir -r requirements.txt

# 6. Define Startup Command (Using gunicorn, as specified in your files)
# Gunicorn binds to 0.0.0.0 on a common port (8000) for web hosting platforms.
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]