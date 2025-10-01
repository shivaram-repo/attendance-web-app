from app import app, db
print("Attempting to initialize database tables...")
with app.app_context():
    db.create_all()
    print("Database tables initialized successfully.")