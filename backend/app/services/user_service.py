import os
from app.models import db
from app.models.user import User


def bootstrap_admin_user() -> None:
    """Create default admin user if no users exist in the database."""
    if db.session.query(User).count() > 0:
        return  # Users already exist, don't bootstrap
    
    admin_username = os.getenv("ADMIN_USERNAME", "admin")
    admin_password = os.getenv("ADMIN_PASSWORD", "password")

    # Warn loudly if default insecure credentials are being used
    if admin_username == "admin" or admin_password == "password":
        import logging
        logging.warning(
            "[SECURITY] Bootstrap is using default credentials (admin/password). "
            "Set ADMIN_USERNAME and ADMIN_PASSWORD env vars before deploying to production!"
        )
    
    admin_user = User(username=admin_username)
    admin_user.set_password(admin_password)
    db.session.add(admin_user)
    db.session.commit()
    print(f"[BOOTSTRAP] Admin user '{admin_username}' created")


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
    if email and User.query.filter_by(email=email).first():
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


def check_login_allowed(user: User) -> tuple[bool, str | None]:
    """Check if the user is currently allowed to log in (not locked)."""
    from datetime import datetime, timezone
    if user.locked_until:
        locked_until = user.locked_until
        if locked_until.tzinfo is None:
            locked_until = locked_until.replace(tzinfo=timezone.utc)
        
        now = datetime.now(timezone.utc)
        if now < locked_until:
            remaining = int((locked_until - now).total_seconds())
            minutes = (remaining // 60) + 1
            return False, f"Account locked. Try again in {minutes} mins."
        else:
            # Lock has expired, reset attempts
            user.locked_until = None
            user.failed_login_attempts = 0
            db.session.commit()
    return True, None


def record_failed_attempt(user: User) -> str:
    """Record a failed login attempt and lock the account if needed."""
    from datetime import datetime, timezone, timedelta
    user.failed_login_attempts += 1
    if user.failed_login_attempts >= 5:
        lock_duration = timedelta(minutes=15)
        user.locked_until = datetime.now(timezone.utc) + lock_duration
        db.session.commit()
        return "Account locked due to multiple failed attempts. Try again in 15 minutes."
    
    db.session.commit()
    attempts_left = 5 - user.failed_login_attempts
    return f"Invalid credentials. {attempts_left} attempts remaining."


def record_successful_login(user: User) -> None:
    """Reset failed attempts on successful login."""
    if user.failed_login_attempts > 0 or user.locked_until:
        user.failed_login_attempts = 0
        user.locked_until = None
        db.session.commit()

