# Stage 1: Build dependencies
FROM python:3.11 AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y build-essential gcc gfortran python3-dev \
                       libatlas-base-dev liblapack-dev libblas-dev && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install essential Python packages
RUN pip install --upgrade pip setuptools wheel

# Copy the requirements file and install dependencies
COPY requirements.txt .

# Install specific versions of Cython, numpy, and scipy first to avoid conflicts
RUN pip install --no-cache-dir cython==0.29.24 numpy==1.26.4 scipy==1.13.1

# Install scikit-learn and imbalanced-learn using precompiled wheels to avoid building from source
RUN pip install --no-cache-dir scikit-learn==1.0.2 imbalanced-learn==0.8.0

# Install the remaining dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Build the final image
FROM python:3.11-slim

WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /usr/local/include /usr/local/include

# Copy the rest of the application code into the container
COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

# Define the command to run the application
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]



