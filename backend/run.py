import os
import sys
from pathlib import Path

# Ensure this script's directory is on sys.path so `import app` works
SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

from app import create_app


def main():
    app = create_app()
    try:
        app.run(host="0.0.0.0", port=5000, debug=True)
    except Exception as e:
        # Print a helpful traceback to the terminal
        import traceback

        traceback.print_exc()
        print(f"Failed to start app: {e}")


if __name__ == "__main__":
    main()
