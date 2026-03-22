#!/usr/bin/env bash
# exit on error
set -o errexit

# Upgrade pip
python -m pip install --upgrade pip

# Install build dependencies in the main environment
python -m pip install "cmake<3.27" "setuptools<70" wheel numpy

# Set environment variables for dlib build
export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_AVX_INSTRUCTIONS=OFF"

# Install dlib with --no-build-isolation so it uses the cmake we just installed
# and sees our environment variables
python -m pip install dlib==19.24.2 --no-build-isolation --no-cache-dir

# Install the rest
python -m pip install -r requirements.txt

python manage.py collectstatic --no-input
python manage.py migrate
