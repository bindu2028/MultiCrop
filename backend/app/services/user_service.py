import os
from app.models import db
from app.models.user import User


def bootstrap_admin_user() -> None:
    """Create default admin user if no users exist in the database."""
    if db.session.query(User).count() > 0:
        return  # Users already exist, don't bootstrap
    
    admin_username = os.getenv("ADMIN_USERNAME", "admin")
    admin_password = os.getenv("ADMIN_PASSWORD", "password")
    
    admin_user = User(username=admin_username)
    admin_user.set_password(admin_password)
    db.session.add(admin_user)
    db.session.commit()
    print(f"✓ Admin user '{admin_username}' created")


def verify_credentials(username: str, password: str) -> bool:
    """Verify username and password against database."""
    user = User.query.filter_by(username=username).first()
    if not user:
        return False
    return user.check_password(password)


def create_user(username: str, password: str, email: str = None) -> User | None:
    """Create a new user in the database."""
    # Check if user already exists
    if User.query.filter_by(username=username).first():
        return None
    
    user = User(username=username, email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    return user


def get_user_by_username(username: str) -> User | None:
    """Get user by username."""
    return User.query.filter_by(username=username).first()


def get_user_by_id(user_id: int) -> User | None:
    """Get user by ID."""
    return User.query.get(user_id)

