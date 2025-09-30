# 1. Base Image: Use a minimal Conda image
FROM continuumio/miniconda3

# 2. Setup Application Directory
WORKDIR /app
COPY requirements.txt .

# 3. CRITICAL FIX: Install all heavy packages via Conda and then install the rest via pip.
# This avoids the C++ compilation that is causing memory and exit code 1 errors.
RUN conda create -n attendance python=3.9 -y && \
    conda install -n attendance -c conda-forge \
        # Install dlib, face-recognition, and opencv from Conda's binary channel
        dlib=19.24.2 \
        face-recognition \
        opencv \
        numpy \
        # Include pip in the environment
        pip -y && \
    \
    # 4. Install remaining, non-problematic dependencies (Flask, gunicorn, etc.)
    # We first use 'grep' to filter out the heavy dependencies already installed by Conda
    grep -vE '^(dlib|face-recognition|opencv|numpy)' requirements.txt > /tmp/light_requirements.txt && \
    /opt/conda/envs/attendance/bin/pip install --no-cache-dir -r /tmp/light_requirements.txt && \
    \
    # 5. Cleanup Conda cache to reduce image size
    conda clean --all -y

# 6. Activate Conda Environment
ENV PATH /opt/conda/envs/attendance/bin:$PATH

# 7. Copy Application Code
COPY . /app

# 8. Define Startup Command
EXPOSE 8000 
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]