# Use a slightly different base image (Ubuntu 20.04/Python 3.9)
# This often resolves tricky dependency chain issues compared to Debian
FROM python:3.9-focal

# 1. Install System Dependencies (CRITICAL STEP)
# Condensing and simplifying the list for better stability.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libjpeg-dev \
    libpng-dev \
    libatlas-base-dev \
    libtesseract-dev \
    gfortran \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Environment Variables
# Essential for dlib compilation
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON
ENV FLASK_STATIC_FOLDER=/app/static

# 3. Setup Application Directory
WORKDIR /app
COPY . /app

# 4. Install Python Dependencies
# This step includes the lengthy compilation of dlib (up to 40 minutes)
RUN pip install --no-cache-dir -r requirements.txt

# 5. Expose Port and Define Startup Command
EXPOSE 10000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:10000", "app:app"]