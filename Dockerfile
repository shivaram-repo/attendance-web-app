# 1. Base Image: Use a minimal Conda image (Conda solves the memory/compilation issues)
FROM continuumio/miniconda3

# 2. Setup Application Directory
WORKDIR /app

# 3. Create Conda Environment and Install Dependencies
# Conda installs pre-built binaries, completely bypassing the memory-heavy C++ compilation.
# We use the 'conda-forge' channel for the latest, robust versions of dlib and face-recognition.
COPY requirements.txt .
RUN conda create -n attendance python=3.9 -y && \
    conda install -n attendance -c conda-forge \
        dlib \
        face-recognition \
        opencv \
        numpy \
        # Install the rest using pip within the conda environment
        pip -y && \
    # Install the remaining Flask/production dependencies via pip
    /opt/conda/envs/attendance/bin/pip install --no-cache-dir -r requirements.txt && \
    # Cleanup Conda cache to reduce image size
    conda clean --all -y

# 4. Activate Conda Environment
ENV PATH /opt/conda/envs/attendance/bin:$PATH

# 5. Copy Application Code
COPY . /app

# 6. Define Startup Command (gunicorn is now run from the Conda environment)
EXPOSE 8000 
# Note: We must explicitly call gunicorn from the Conda environment path
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "app:app"]