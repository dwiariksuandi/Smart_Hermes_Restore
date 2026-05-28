#!/usr/bin/env python3
import time
import subprocess
from pathlib import Path

HERMES = Path("/home/hiryu/.hermes")
WATCH_PATHS = [HERMES, HERMES / "vault"]
MAPPER = HERMES / "workspace_mapper.py"
INTERVAL = 30  # seconds

def run_mapper():
    try:
        subprocess.run([str(HERMES / "venv/bin/python"), str(MAPPER)], 
                       capture_output=True, check=False)
    except Exception:
        pass

def main():
    print("Workspace mapper watcher started (polling every 30s)")
    last_mtime = 0
    while True:
        try:
            # Check if any watched file changed
            changed = False
            for base in WATCH_PATHS:
                for p in base.rglob("*"):
                    if p.is_file() and not p.name.startswith('.'):
                        try:
                            m = p.stat().st_mtime
                            if m > last_mtime:
                                changed = True
                                break
                        except (FileNotFoundError, PermissionError):
                            continue
                if changed:
                    break
            if changed:
                last_mtime = time.time()
                run_mapper()
        except KeyboardInterrupt:
            break
        time.sleep(INTERVAL)

if __name__ == "__main__":
    main()
