#!/usr/bin/env bash
# exit on error
set -o errexit

# Upgrade pip
python -m pip install --upgrade pip

# Pin cmake to a known stable version for dlib
python -m pip install "cmake<3.28" numpy

# Fix for "Compatibility with CMake < 3.5 has been removed from CMake"
# And we also add -DDUSE_AVX_INSTRUCTIONS=OFF to save memory/compatibility
export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_AVX_INSTRUCTIONS=OFF"

# Install dlib separately with no-cache to save memory
python -m pip install dlib==19.24.2 --no-cache-dir

# Install the rest
python -m pip install -r requirements.txt

python manage.py collectstatic --no-input
python manage.py migrate
