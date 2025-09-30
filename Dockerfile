# Start from a Python image that includes necessary C++ build tools (like Debian or Alpine)
# We use a slim image to keep the size down
FROM python:3.11-slim

# Set environment variables for dlib/face_recognition to work correctly
ENV PYTHONPATH "${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"

# Install system dependencies required for OpenCV and dlib
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libgtk2.0-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libswscale-dev \
    wget \
    unzip \
    # Clean up APT files to reduce image size
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the requirements file and install Python dependencies
COPY requirements.txt ./
# Install only the wheels if available to skip compiling dlib 
# Fallback to direct install if necessary
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code
COPY . .

# Expose the port your application runs on (Render uses $PORT)
ENV PORT 10000 
EXPOSE ${PORT}

# Define the command to run your application (same as your Procfile)
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:10000"] 
# Note: Render will override the port if needed, but 10000 is a common convention.