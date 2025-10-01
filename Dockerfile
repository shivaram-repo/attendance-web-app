# 1. Base Image: Use a minimal Conda image (The most robust base for dlib/OpenCV)
FROM continuumio/miniconda3

# 2. Setup Application Directory
WORKDIR /app
COPY requirements.txt .

# 3. CRITICAL FIX: Install all heavy packages via Conda from the trusted 'conda-forge' channel
RUN conda create -n attendance python=3.9 -y && \
    conda install -n attendance -c conda-forge \
        dlib=19.24.2 \
        face-recognition \
        opencv \
        numpy \
        psycopg2 \
        pip -y && \
    \
    # 4. Filter requirements.txt to REMOVE packages already installed by Conda
    grep -vE '^(dlib|face-recognition|opencv|numpy)' requirements.txt > /tmp/light_requirements.txt && \
    \
    # 5. Install the remaining, non-problematic Python dependencies (Flask, gunicorn, etc.)
    /opt/conda/envs/attendance/bin/pip install --no-cache-dir -r /tmp/light_requirements.txt && \
    \
    # 6. Final Cleanup to reduce image size
    conda clean --all -y

# 7. Activate Conda Environment for all subsequent commands
ENV PATH /opt/conda/envs/attendance/bin:$PATH

# 8. Copy Application Code
COPY . /app

# 9. Define Startup Command (Uses the gunicorn installed in the Conda environment)
EXPOSE 8000 
# FINAL FIX: Reduce Gunicorn workers to 1 to reduce memory usage below the 512Mi limit.
CMD ["sh", "-c", "python init_db.py && gunicorn -w 1 --threads 4 --timeout 90 -b 0.0.0.0:8000 app:app"]

