# 1. Base Image: Use the currently supported stable Debian 11 (Bullseye)
FROM python:3.9-bullseye

# 2. Install Essential System Dependencies
# These are needed for NumPy, OpenCV, and runtime linking.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # Compilers and development tools (still required for OpenCV/face-recognition)
    build-essential \
    cmake \
    python3-dev \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    # Final cleanup
    && rm -rf /var/lib/apt/lists/*

# 3. Configure Environment Variables (Keep for other dependencies)
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
ENV DLIB_NO_GUI_SUPPORT=ON

# 4. Setup Application Directory
WORKDIR /app
COPY requirements.txt /app/

# 5. CRITICAL FIX: Install pre-compiled Dlib binary
# We use 'dlib-bin' (the binary version on PyPI) to completely skip the time-consuming 
# and failure-prone source compilation of dlib.
RUN pip install --no-cache-dir dlib-bin==19.24.2

# 6. Install Remaining Python Dependencies
# We filter out the original 'dlib==19.24.2' entry from requirements.txt 
# because it's now installed as 'dlib-bin'.
RUN sed '/^dlib/d' requirements.txt > /tmp/requirements_rest.txt && \
    pip install --no-cache-dir -r /tmp/requirements_rest.txt

# 7. Copy Application Code
COPY . /app

# 8. Define Startup Command
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]