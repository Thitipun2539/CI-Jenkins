#!/bin/bash

# Install OpenJDK 1.8 and wget using yum package manager
yum install java-1.8.0-openjdk.x86_64 wget -y

# Create directories for Nexus installation and temporary files
mkdir -p /opt/nexus/
mkdir -p /tmp/nexus/

# Change to the temporary Nexus directory
cd /tmp/nexus/

# Define the URL for downloading the latest Nexus release
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"

# Download the Nexus tarball and save it as nexus.tar.gz
wget $NEXUSURL -O nexus.tar.gz

# Wait for 10 seconds to ensure the download completes
sleep 10

# Extract the contents of the Nexus tarball
EXTOUT=`tar xzvf nexus.tar.gz`

# Get the name of the extracted directory
NEXUSDIR=`echo $EXTOUT | cut -d '/' -f1`

# Wait for 5 seconds to ensure extraction completes
sleep 5

# Remove the downloaded tarball to clean up
rm -rf /tmp/nexus/nexus.tar.gz

# Copy the extracted files to the /opt/nexus/ directory
cp -r /tmp/nexus/* /opt/nexus/

# Wait for 5 seconds to ensure files are copied
sleep 5

# Create a new user named 'nexus'
useradd nexus

# Change ownership of the /opt/nexus directory to the nexus user and group
chown -R nexus.nexus /opt/nexus 

# Create a systemd service file for Nexus
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Set the run_as_user variable to 'nexus' in the Nexus configuration file
echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd manager configuration to apply the new service
systemctl daemon-reload

# Start the Nexus service
systemctl start nexus

# Enable the Nexus service to start on boot
systemctl enable nexus

