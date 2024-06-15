# Use the official Nginx image as the base image for the web server
FROM nginx

# Add labels for project metadata
LABEL "Project"="Vprofile"
LABEL "Author"="Thitipun"

# Remove the default Nginx configuration file
RUN rm -rf /etc/nginx/conf.d/default.conf

# Copy the custom Nginx configuration file to the Nginx configuration directory
COPY nginvproapp.conf /etc/nginx/conf.d/vproapp.conf