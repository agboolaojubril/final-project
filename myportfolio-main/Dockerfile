# Use the official Nginx Alpine image
FROM nginx:alpine

# Metadata
LABEL maintainer="Agboola Jubril"
LABEL project="Jubril Cloud World Portfolio"
LABEL description="Personal Cloud & DevOps Portfolio Website"

# Remove the default Nginx web files
RUN rm -rf /usr/share/nginx/html/*

# Copy portfolio files into the Nginx web directory
COPY . /usr/share/nginx/html/

# Expose HTTP port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
