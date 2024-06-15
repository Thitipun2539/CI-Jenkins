pipeline {
    agent any
    // Define the tools required for the pipeline
    tools {
        maven "MAVEN3" // Use the Maven tool named "MAVEN3"
        jdk "OracleJDK8" // Use the JDK tool named "OracleJDK8"
    }

    environment {
        // Define environment variables to be used to set up Nexus
        SNAP_REPO = "vprofile-snapshot" // Snapshot repository name
        NEXUS_USER = "admin" // Nexus repository user
        NEXUS_PASS = "admin123" // Nexus repository password
        RELEASE_REPO = "vprofile-release" // Release repository name
        CENTRAL_REPO = "vpro-maven-central" // Central repository name
        NEXUSIP = "172.31.60.150" // Private IP of Nexus server
        NEXUSPORT = "8081" // Port number of Nexus server
        NEXUS_GRP_REPO = "vpro-maven-group" // Group repository name in Nexus
        NEXUS_LOGIN = "nexuslogin" // Nexus login credentials (username:password)
    }

    stages {
        // Define the stages of the pipeline
        stage('Build') {
            steps {
                // Execute Maven build command
                sh 'mvn -s settings.xml -DskipTests install' // Run Maven with custom settings and skip tests
            }
        }
    }
}