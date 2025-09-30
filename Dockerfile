# Use the full, stable Python base image (less likely to have missing headers/links)
FROM python:3.9-buster

# 1. Install System Dependencies (CRITICAL STEP)
# Use a single, robust RUN command for stability and better caching.
# 'apt-get clean' is essential for keeping the image size down.
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
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
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Configure Environment Variables
# Essential for dlib and face-recognition compilation
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON
# Set the location where Flask will store static files
ENV FLASK_STATIC_FOLDER=/app/static

# 3. Setup Application Directory
WORKDIR /app
COPY . /app

# 4. Install Python Dependencies
# This step should now succeed because the system libraries are installed
RUN pip install --no-cache-dir -r requirements.txt

# 5. Expose Port and Define Startup Command
# Render requires the app to listen on the port defined by the environment variable
EXPOSE 10000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:10000", "app:app"]