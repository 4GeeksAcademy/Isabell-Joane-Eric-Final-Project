# Use the official Python image from the Docker Hub
FROM python:3.11

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container at /app
COPY requirements.txt .

# Install system dependencies and additional libraries
RUN apt-get update && \
    apt-get install -y build-essential gcc gfortran python3-dev \
                       libatlas-base-dev liblapack-dev libblas-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Cython first to ensure it is available for building other packages
RUN pip install --no-cache-dir cython==0.29.24

# Install scikit-learn and other packages using wheels to avoid compilation issues
RUN pip install --no-cache-dir numpy scipy scikit-learn

# Install the remaining dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

# Define the command to run the application
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]

