# Use the official Miniconda image
FROM continuumio/miniconda3

# Set the working directory in the container
WORKDIR /app

# Copy the requirements.txt file into the container at /app
COPY requirements.txt .

# Create a Conda environment with Python 3.11
RUN conda create -n myenv python=3.11 -y

# Activate the environment and install the necessary packages
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]
RUN conda install -c conda-forge cython numpy=1.26.4 scipy=1.13.1 -y
RUN pip install scikit-learn==1.0.2 imbalanced-learn==0.8.0
RUN pip install -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

# Define the command to run the application
CMD ["conda", "run", "--no-capture-output", "-n", "myenv", "gunicorn", "-w", "4", "-b", "0.0.0.0:80", "app:app"]




