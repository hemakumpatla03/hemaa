#!/usr/bin/env bash
# exit on error
set -o errexit

# Upgrade pip
python -m pip install --upgrade pip

# Install cmake and numpy first as they are build dependencies
python -m pip install cmake numpy

# Install dlib separately with no-cache to save memory
# dlib compilation is very memory-intensive
python -m pip install dlib==19.24.2 --no-cache-dir

# Install the rest of the requirements
python -m pip install -r requirements.txt

python manage.py collectstatic --no-input
python manage.py migrate
