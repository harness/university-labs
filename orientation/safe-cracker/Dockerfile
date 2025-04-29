# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy the safe-cracker app directory contents
COPY orientation/safe-cracker/package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the app source
COPY orientation/safe-cracker/ .

# Build the app
RUN npm run build

# Expose application port (adjust if needed)
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
