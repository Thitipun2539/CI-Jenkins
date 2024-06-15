# Use the official OpenJDK 11 image as the base image for the build stage
FROM openjdk:11 AS BUILD_IMAGE

# Update package lists and install Maven
RUN apt update && apt install maven -y

# Clone the vprofile project repository from GitHub
RUN git clone https://github.com/Thitipun2539/CI-Jenkins.git

# Change directory to the cloned repository, checkout the 'docker' branch, and build the project using Maven
RUN cd vprofile-project && git checkout docker && mvn install

# Use the official Tomcat 9 image with JRE 11 for the runtime stage
FROM tomcat:9-jre11

# Remove the default web applications provided by Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file built in the build stage to the Tomcat webapps directory and rename it to ROOT.war
# This will be the main application served by Tomcat
COPY --from=BUILD_IMAGE vprofile-project/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 for the Tomcat server
EXPOSE 8080

# Start the Tomcat server
CMD ["catalina.sh", "run"]