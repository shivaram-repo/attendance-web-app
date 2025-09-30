# Use Python 3.9 based on Debian 11 (Bullseye), which is the correct, available tag
FROM python:3.9-bullseye

# 1. Install System Dependencies (CRITICAL STEP for dlib/opencv)
# Use a single, robust RUN command for stability.
# The `dlib` and `opencv` dependencies are crucial here.
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
    # Clean up to keep the final image size down
    && rm -rf /var/lib/apt/lists/*

# 2. Configure Environment Variables
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON
ENV FLASK_STATIC_FOLDER=/app/static

# 3. Setup Application Directory
WORKDIR /app
COPY . /app

# 4. Install Python Dependencies
# This step should now compile dlib successfully.
RUN pip install --no-cache-dir -r requirements.txt

# 5. Expose Port and Define Startup Command
EXPOSE 10000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:10000", "app:app"]