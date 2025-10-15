# Facial Recognition Attendance Tracker (FRAT)

A robust, memory-efficient web application designed for automated employee attendance tracking using cutting-edge facial recognition technology. Built with Flask, the system provides a simple web interface for new user registration and a quick, live camera check-in process.

---

## ✨ Features
| Feature | Description |
| :--- | :--- |
| **User Onboarding** | Secure registration: **Name**, **Employee ID**, **Face Image** upload. 🧑‍💻 |
| **Facial Recognition** | **128D facial encoding** (Dlib) generated and stored as a secure binary blob. 💾 |
| **Check-In Process** | **Real-time attendance** via web camera; compares live encoding against database. 📸 |
| **Data Management** | Attendance records (**User ID, Date, Time, Status**) stored via **Flask-SQLAlchemy**. 📊 |
| **Deployment** | **Memory-Optimized** (Conda/Docker) for **constrained cloud environments** ($\le$ 512MiB). ☁️ |

---

## 💻 Tech Stack

| Category | Technology | Purpose |
| :--- | :--- | :--- |
| **Backend Framework** | **Python 3.9 (Flask)** | Core web application logic and routing. |
| **Facial Recognition** | **Dlib / `face-recognition`** | Core library for deep learning-based face encoding and comparison. |
| **Image Processing** | **OpenCV (`opencv-python`)** | Image handling, especially for processing uploaded and captured images. |
| **Database ORM** | **Flask-SQLAlchemy** | Object-Relational Mapper for the SQLite database (`database.db`). |
| **Production Server** | **Gunicorn** | Production WSGI HTTP server. |
| **Environment/Deployment**| **Conda / Docker** | Used for reliable, memory-efficient installation of binary dependencies. |

---

## 📺 Live Demo:
 **https://attendance-web-app-14vp.onrender.com/**
 
 (Feel free to use a fake face image or any image you like. Please note that all data will be deleted periodically to protect your privacy.)

 ---

## ⚙️ Local Setup

Follow these steps to set up the project on your local machine.

### Prerequisites

* Python 3.9 or latest version
* **Conda** (Miniconda or Anaconda) is highly recommended due to the dependencies.

---

### Step-by-Step Installation

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/shivaram-repo/attendance-web-app.git
    cd face-attendance-system
    ```

2.  **Create and Activate Conda Environment:**
    ```bash
    conda create -n attendance python=3.9 -y
    conda activate attendance
    ```

3.  **Install Dependencies:**
    You must install the heavy packages (`dlib`, `opencv`) via Conda first, and the rest via `pip`.

    ```bash
    # 3a. Install the heavy binaries from conda-forge
    conda install -c conda-forge dlib=19.24.2 face-recognition opencv numpy -y

    # 3b. Install the remaining Python packages (Flask, Gunicorn, etc.)
    pip install -r requirements.txt
    ```

4.  **Run the Application:**

    ```bash
    python app.py
    ```

The application will start on `http://127.0.0.1:5000` (or `http://localhost:5000`).

---

## 🐳 Deployment (Dockerized)

The provided **`Dockerfile`** uses a robust Conda-based multi-step process to ensure a successful build and a low-memory runtime, which is essential for deployment on platforms with strict resource limits (like Render or Heroku).

1.  **Build the Docker Image:**
    ```bash
    docker build -t face-attendance-app .
    ```

2.  **Run the Container:**
    ```bash
    docker run -d -p 8000:8000 --name attendance-server face-attendance-app
    ```
    *(Note: The app runs on port 8000 inside the container, as configured in the `Dockerfile` and `CMD`.)*

    ---

### Key Deployment Optimizations

* **Conda:** Used to install resource-heavy packages (`dlib`, `opencv`) as pre-compiled binaries, avoiding the C++ compilation causing "Out of memory" errors during the build phase.
* **Gunicorn:** The command is set to `CMD ["gunicorn", "-w", "1", "--threads", "4", "-b", "0.0.0.0:8000", "app:app"]` to limit the number of worker processes to **one**. This aggressively reduces the runtime memory usage, preventing the "Out of memory (used over 512Mi)" failure during startup.

---

## 🤝 Contribution

Feel free to fork the repository and contribute. For major changes, please open an issue first to discuss what you would like to change.

---

* *Note: This project was built by the help of AI and is intended for educational purposes.*
