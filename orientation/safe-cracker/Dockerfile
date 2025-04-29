# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the app source code
COPY . .

# Build the application
RUN npm run build

# Expose application port (adjust if needed)
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
