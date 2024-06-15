# Use the official MySQL 8.0.33 image as the base image for the database
FROM mysql:8.0.33

# Add labels for project metadata
LABEL "Project"="Vprofile"
LABEL "Author"="Thitipun"

# Set environment variables for the MySQL root password and the database name
ENV MYSQL_ROOT_PASSWORD="vprodbpass"
ENV MYSQL_DATABASE="accounts"

# Add the database backup file to the initialization directory
# This will automatically restore the database when the container starts
ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql
