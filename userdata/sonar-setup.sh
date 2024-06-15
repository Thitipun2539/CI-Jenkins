#!/bin/bash

# Backup the current sysctl.conf file
cp /etc/sysctl.conf /root/sysctl.conf_backup

# Update the sysctl.conf file with new kernel parameters
cat <<EOT> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
EOT

# Backup the current security limits configuration
cp /etc/security/limits.conf /root/sec_limit.conf_backup

# Update the security limits configuration for the sonarqube user
cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    409
EOT

# Update the package list
sudo apt-get update -y

# Install OpenJDK 11
sudo apt-get install openjdk-11-jdk -y

# Select the default Java version
sudo update-alternatives --config java

# Verify the Java installation
java -version

# Add the PostgreSQL repository key
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -

# Add the PostgreSQL repository
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

# Update the package list again to include PostgreSQL packages
sudo apt update

# Install PostgreSQL and its additional components
sudo apt install postgresql postgresql-contrib -y

# Enable and start the PostgreSQL service
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

# Set the password for the postgres user
sudo echo "postgres:admin123" | chpasswd

# Create a new PostgreSQL user for SonarQube
runuser -l postgres -c "createuser sonar"

# Set the password for the sonar user and create the SonarQube database
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

# Restart the PostgreSQL service
systemctl restart postgresql

# Verify PostgreSQL is running
netstat -tulpena | grep postgres

# Create a directory for SonarQube
sudo mkdir -p /sonarqube/
cd /sonarqube/

# Download SonarQube
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip

# Install the unzip utility
sudo apt-get install zip -y

# Unzip the SonarQube archive to /opt directory
sudo unzip -o sonarqube-8.3.0.34182.zip -d /opt/

# Move the extracted SonarQube directory to /opt/sonarqube
sudo mv /opt/sonarqube-8.3.0.34182/ /opt/sonarqube

# Create a user and group for SonarQube
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar

# Set ownership of the SonarQube directory to the sonar user and group
sudo chown sonar:sonar /opt/sonarqube/ -R

# Backup the SonarQube configuration file
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

# Update the SonarQube configuration file with database connection details
cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

# Create a systemd service file for SonarQube
cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd to apply the new service
systemctl daemon-reload

# Enable the SonarQube service to start on boot
systemctl enable sonarqube.service

# Install Nginx
apt-get install nginx -y

# Remove default Nginx site configurations
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default

# Create a new Nginx site configuration for SonarQube
cat <<EOT> /etc/nginx/sites-available/sonarqube
server{
    listen      80;
    server_name sonarqube.groophy.in;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

# Enable the new Nginx site configuration
ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube

# Enable the Nginx service to start on boot
systemctl enable nginx.service

# Allow traffic on ports 80, 9000, and 9001
sudo ufw allow 80,9000,9001/tcp

# Announce system reboot and wait for 30 seconds
echo "System reboot in 30 sec"
sleep 30

# Reboot the system
reboot
