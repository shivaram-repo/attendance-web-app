# Use a Debian base image that includes essential development tools
FROM python:3.9-slim-buster

# 1. Install System Dependencies (CRITICAL STEP)
# This includes all necessary libraries for dlib and numpy compilation
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    libtesseract-dev \
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libtiff-dev \
    libfreetype6-dev \
    libatlas-base-dev \
    gfortran \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Environment Variables
# Essential for dlib and face-recognition to find components
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON
ENV NUMPY_INCLUDE_DIR=/usr/include/python3.9 
# For older dlib/numpy versions, sometimes necessary

# 3. Setup Application Directory
WORKDIR /app
COPY . /app

# 4. Install Python Dependencies
# This step will now succeed because the system libraries are installed
# We use --no-cache-dir to keep the final image size down
RUN pip install --no-cache-dir -r requirements.txt

# 5. Expose Port and Define Startup Command
# Render requires the app to listen on the port defined by the environment variable
EXPOSE 10000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:10000", "app:app"]