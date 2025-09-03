# Production Dockerfile
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files
COPY Result/package*.json ./
RUN npm ci

# Copy source code
COPY Result/ .

# Build the application
RUN npm run build

# Production stage
FROM nginx:alpine AS production

# Copy build files to nginx
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

