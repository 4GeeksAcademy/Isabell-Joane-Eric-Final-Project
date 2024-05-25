# Use the official ContinuumIO/miniconda3 image
FROM continuumio/miniconda3

# Set the working directory
WORKDIR /app

# Copy requirements.txt first to leverage Docker cache
COPY requirements.txt .

# Create a new conda environment with the specified Python version
RUN conda create -n myenv python=3.10.10 -y

# Activate the new environment
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]

# Install necessary build tools
RUN apt-get update && apt-get install -y build-essential

# Install cython, numpy, and scipy from conda-forge to ensure precompiled binaries are used
RUN conda install -c conda-forge cython numpy=1.23.5 scipy=1.8.1 -y

# Install scikit-learn and imbalanced-learn using conda to ensure precompiled binaries are used
RUN conda install -c conda-forge scikit-learn=1.0.2 imbalanced-learn=0.8.0 -y

# Install the remaining dependencies from requirements.txt using pip
RUN pip install -r requirements.txt

# Install Gunicorn
RUN pip install gunicorn

# Copy the rest of the application code into the container
COPY . .

# Expose the port
EXPOSE 8000

# Set the entry point for the Docker container
CMD ["conda", "run", "--no-capture-output", "-n", "myenv", "gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

