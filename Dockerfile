# Use an official Python runtime as a parent image
FROM python:3.10.12-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies for OpenCV and YOLOv8
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Create media and static directories
RUN mkdir -p media static staticfiles

# Collect static files
RUN python manage.py collectstatic --no-input

# Expose port
EXPOSE 10000

# Start command
# Runs migrations and starts gunicorn with minimal memory footprint
CMD python manage.py migrate && gunicorn face_detection_system.wsgi:application --bind 0.0.0.0:10000 --timeout 120 --workers 1 --threads 1 --worker-tmp-dir /dev/shm
