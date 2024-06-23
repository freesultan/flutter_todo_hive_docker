# Use the official Dart image with Flutter pre-installed
FROM cirrusci/flutter:stable

# Create and set the working directory
WORKDIR /app

# Copy the pubspec files
COPY pubspec.yaml pubspec.lock ./

# Install the dependencies
RUN flutter pub get

# Copy the rest of the application files
COPY . .

# Expose port 8080 for the web server
EXPOSE 8080

# Run the application
CMD ["flutter", "run", "-d", "chrome", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
