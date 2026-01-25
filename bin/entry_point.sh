#!/bin/bash
set -euo pipefail

echo "Entry point script running"

CONFIG_FILE=_config.yml

# Wait for volume to be mounted and files to be available
wait_for_files() {
    echo "Waiting for files to be available..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if [ -f "$CONFIG_FILE" ] && [ -f "Gemfile" ]; then
            echo "Files are available, proceeding..."
            return 0
        fi
        echo "Attempt $((attempt + 1))/$max_attempts: Waiting for $CONFIG_FILE and Gemfile..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "ERROR: Files not available after $max_attempts attempts"
    echo "Current directory contents:"
    ls -la || true
    exit 1
}

# Function to manage Gemfile.lock
manage_gemfile_lock() {
    git config --global --add safe.directory '*'
    if command -v git &> /dev/null && [ -f Gemfile.lock ]; then
        if git ls-files --error-unmatch Gemfile.lock &> /dev/null; then
            echo "Gemfile.lock is tracked by git, keeping it intact"
            git restore Gemfile.lock 2>/dev/null || true
        else
            echo "Gemfile.lock is not tracked by git, removing it"
            rm Gemfile.lock
        fi
    fi
}

start_jekyll() {
    echo "Starting Jekyll..."
    manage_gemfile_lock
    
    # Check if config file exists before starting
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: $CONFIG_FILE not found!"
        echo "Current directory: $(pwd)"
        echo "Directory contents:"
        ls -la || true
        exit 1
    fi
    
    if [ "${JEKYLL_ENV:-development}" = "production" ]; then
        echo "Running in PRODUCTION mode (No Watch, No LiveReload)..."
        bundle exec jekyll serve --port=4000 --host=0.0.0.0 --verbose --trace &
    else
        echo "Running in DEVELOPMENT mode..."
        bundle exec jekyll serve --watch --port=4000 --host=0.0.0.0 --livereload --verbose --trace --force_polling &
    fi
}

# Main execution
wait_for_files
start_jekyll

while true; do
    if [ -f "$CONFIG_FILE" ]; then
        inotifywait -q -e modify,move,create,delete $CONFIG_FILE
        if [ $? -eq 0 ]; then
            echo "Change detected to $CONFIG_FILE, restarting Jekyll"
            jekyll_pid=$(pgrep -f jekyll) || true
            if [ -n "$jekyll_pid" ]; then
                kill -KILL $jekyll_pid || true
            fi
            sleep 2
            start_jekyll
        fi
    else
        echo "WARNING: $CONFIG_FILE disappeared, waiting for it to reappear..."
        sleep 5
    fi
done
