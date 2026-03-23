# Use an official Python runtime as a parent image
FROM python:3.10-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies for dlib, face_recognition, and opencv
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    libopenblas-dev \
    liblapack-dev \
    libx11-dev \
    libgtk-3-dev \
    libboost-python-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    pkg-config \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
# Pin build dependencies for stability
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir numpy==1.26.3 "setuptools<70" wheel

# Install dlib with specific flags to ensure it works on Render
# We force 1 thread (-j 1) and disable AVX to prevent RAM usage from exceeding 8GB
RUN export CMAKE_ARGS="-DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DUSE_AVX_INSTRUCTIONS=OFF -DDLIB_USE_CUDA=0 -DDLIB_NO_GUI_SUPPORT=1" && \
    export MAKEFLAGS="-j 1" && \
    pip install --no-cache-dir dlib==19.24.2 --no-build-isolation

# Install the rest of the requirements
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Create media and static directories
RUN mkdir -p media static staticfiles

# Collect static files
RUN python manage.py collectstatic --no-input

# Expose port
EXPOSE 10000

# Start command
CMD python manage.py migrate && gunicorn face_detection_system.wsgi:application --bind 0.0.0.0:10000
