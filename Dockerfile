# 1. Base Image: Use a full, stable Python 3.9 image on Debian 11 (Bullseye)
FROM python:3.9-bullseye

# 2. Install System Dependencies (CRITICAL FIX: Adding python3-dev and cleaning up)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Essential compilation tools
    build-essential \
    cmake \
    gfortran \
    # FIX: Explicitly adding python3-dev for headers
    python3-dev \
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
# Set the application's working directory
WORKDIR /app

# 4. Copy and Install Python Dependencies
COPY requirements.txt /app/
# This step is the slowest, as dlib and face-recognition compile
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy Application Code and Define Startup Command
COPY . /app

# The application uses Flask with gunicorn on port 8000 (common for Render/Heroku)
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]