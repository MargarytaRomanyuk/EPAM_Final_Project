FROM tomcat:8.5.47-jdk8-openjdk
  
COPY ./target/*.war /usr/local/tomcat/webapps
