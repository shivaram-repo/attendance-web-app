from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import face_recognition
import numpy as np
import datetime
import os
import json
import face_recognition_models

# Flask App Configuration 
app = Flask(__name__)
CORS(app) 

# Configure PostgreSQL database URI. 
# Render will inject the actual URL into the DATABASE_URL environment variable.
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL').replace("postgres://", "postgresql://", 1) \
    if os.environ.get('DATABASE_URL') else 'sqlite:///database.db'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
#Database Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    employee_id = db.Column(db.String(50), unique=True, nullable=False)
    # Store face embedding as a binary blob
    face_embedding = db.Column(db.LargeBinary, nullable=False) 
    
    def __repr__(self):
        return f'<User {self.employee_id}>'

class Attendance(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    date = db.Column(db.Date, nullable=False)
    time = db.Column(db.Time, nullable=False)
    status = db.Column(db.String(10), nullable=False, default='Present')
    
    # Relationship for easy access
    user = db.relationship('User', backref=db.backref('attendances', lazy=True))

#Initial Setup / Routes for UI
@app.route('/')
def home():
    """Main attendance page."""
    return render_template('attendance.html')

@app.route('/register_ui')
def register_ui():
    """Registration form page."""
    return render_template('register.html')

#API Endpoints

# Register new user
@app.route('/register', methods=['POST'])
def register():
    #(Error checking remains the same) 
    if 'name' not in request.form or 'employee_id' not in request.form or 'image' not in request.files:
        return jsonify({"status": "failed", "message": "Missing form data"}), 400

    name = request.form.get('name')
    emp_id = request.form.get('employee_id')
    file = request.files.get('image')

    if not name or not emp_id or not file:
        return jsonify({"status": "failed", "message": "All fields are required"}), 400

    # Load image and extract embedding
    try:
        img = face_recognition.load_image_file(file)
        encodings = face_recognition.face_encodings(img)
    except Exception as e:
        return jsonify({"status": "failed", "message": f"Image processing failed: {str(e)}"}), 500


    if len(encodings) == 0:
        return jsonify({"status": "failed", "message": "No face detected in image"}), 400

    # Convert numpy array to bytes for storage
    encoding_bytes = encodings[0].tobytes()

    try:
        # Check for existing employee ID
        if User.query.filter_by(employee_id=emp_id).first():
             return jsonify({"status": "failed", "message": "Employee ID already exists"}), 409
             
        new_user = User(
            name=name,
            employee_id=emp_id,
            face_embedding=encoding_bytes
        )
        db.session.add(new_user)
        db.session.commit()
        return jsonify({"status": "success", "message": "User registered successfully"})
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "failed", "message": f"Database error: {str(e)}"}), 500

# Mark attendance
@app.route('/attendance', methods=['POST'])
def attendance():
    if 'image' not in request.files:
        return jsonify({"status": "failed", "message": "No image part in the request"}), 400

    file = request.files.get('image')
    if not file:
        return jsonify({"status": "failed", "message": "No image file provided"}), 400

    try:
        img = face_recognition.load_image_file(file)
        encodings = face_recognition.face_encodings(img)
    except Exception as e:
        return jsonify({"status": "failed", "message": f"Image processing failed: {str(e)}"}), 500

    if len(encodings) == 0:
        return jsonify({"status": "failed", "message": "No face detected"}), 400

    encoding = encodings[0]

    # Retrieve all users
    users = User.query.all()
    
    for user in users:
        # Convert stored binary data back to numpy array
        db_encoding = np.frombuffer(user.face_embedding, dtype=np.float64) # face_recognition uses float64
        
        # Ensure the shape is correct (1x128)
        db_encoding = db_encoding.reshape(-1, 128)[0]
        
        # Compare faces
        matches = face_recognition.compare_faces([db_encoding], encoding, tolerance=0.6)

        if matches and matches[0]:
            now = datetime.datetime.now()
            today = now.date()
            
            # Check if attendance for this user has already been marked today
            already_marked = Attendance.query.filter_by(user_id=user.id, date=today).first()
            
            if already_marked:
                return jsonify({"status": "already_marked", "message": f"Attendance already marked for {user.name} today"})

            # Mark new attendance
            new_attendance = Attendance(
                user_id=user.id, 
                date=today, 
                time=now.time(), 
                status="Present"
            )
            db.session.add(new_attendance)
            db.session.commit()
            return jsonify({"status": "success", "message": f"Attendance marked for {user.name}"})

    return jsonify({"status": "failed", "message": "Unknown user. Please register first."}), 404

#Main Execution
if __name__ == '__main__':
    # Create database tables if they don't exist
    with app.app_context():
        db.create_all()
    # For local development (use gunicorn for production)
    app.run(debug=True, host='0.0.0.0', port=5000)
