# Use the official Flutter image
FROM cirrusci/flutter:3.7.7

# Install required packages
RUN apt-get update && apt-get install -y libglu1-mesa

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Run Flutter doctor to check the environment
RUN flutter doctor

# Expose port for the Flutter development server
EXPOSE 8080

# Set the entry point to start the app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080"]