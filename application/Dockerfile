# Use the official Python image from Docker Hub
FROM python:3.8

# Set the working directory in the container
WORKDIR /app

# Copy the entire content of the local library-management-system directory to the container
COPY library-management-system /app/library-management-system

# Set the environment variables
ENV DB_HOST placeholder_host
ENV DB_USER placeholder_user
ENV DB_PASSWORD placeholder_password
ENV DB_NAME placeholder_db


# Change to the library-management-system directory
WORKDIR /app/library-management-system

# Install Gunicorn and any other dependencies your application needs (assuming you have a requirements.txt file)
RUN pip install --no-cache-dir gunicorn && \
    pip install --no-cache-dir -r requirements.txt



# Specify the command to run your application using Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]


