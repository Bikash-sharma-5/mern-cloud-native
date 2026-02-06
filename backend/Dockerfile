# Use a slim Node image for smaller size
FROM node:18-slim

# Set working directory
WORKDIR /app

# Copy package files first (to cache layers)
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Start the application
CMD ["node", "server.js"]