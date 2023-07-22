FROM ubuntu:latest

USER root

# Copy resources and deployments to the container
COPY ./resources/ /resources/
COPY ./deployments/ /deployments/

VOLUME [ "/deployments" ]


# Modify workdir to app
WORKDIR /app

# Install openjdk-11-jdk
RUN apt-get update && apt-get install -y curl tar openjdk-11-jdk

# Download and install wildfly 22.0.1.Final
RUN curl -LO https://download.jboss.org/wildfly/22.0.1.Final/wildfly-22.0.1.Final.tar.gz

# Unzip wildfly
RUN tar -zxf wildfly-22.0.1.Final.tar.gz

# Remove wildfly zip
RUN rm wildfly-22.0.1.Final.tar.gz

# Rename wildfly folder
RUN mv wildfly-22.0.1.Final wildfly

# Modify the standalone.conf file to increase the memory
RUN sed -i 's|-Xms64m -Xmx3G -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=2G -Djava.net.preferIPv4Stack=true|-Xms128m -Xmx2G -XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=512M -Djava.net.preferIPv4Stack=false|' /app/wildfly/bin/standalone.conf

# Allow connections from outside the container
RUN sed -i 's|<interface name="management">.*<inet-address value="${jboss.bind.address.management:127.0.0.1}"/>|<interface name="management">\n<inet-address value="${jboss.bind.address.management:127.0.0.1}">|' /app/wildfly/standalone/configuration/standalone.xml \
    && sed -i 's|<inet-address value="${jboss.bind.address.management:127.0.0.1}"/>|<any-address/>|' /app/wildfly/standalone/configuration/standalone.xml \
    && sed -i 's|<interface name="public">.*<inet-address value="${jboss.bind.address:127.0.0.1}"/>|<interface name="public">\n<inet-address value="${jboss.bind.address:127.0.0.1}">|' /app/wildfly/standalone/configuration/standalone.xml \
    && sed -i 's|<inet-address value="${jboss.bind.address:127.0.0.1}"/>|<any-address/>|' /app/wildfly/standalone/configuration/standalone.xml

# Create user for management console
RUN /app/wildfly/bin/add-user.sh --silent=true admin nimda 

# Expose ports
# 8080 - HTTP Port
# 9990 - Management Port
# 5432 - Database Port
EXPOSE 8080 9990 5432

# Set the default command to run on boot
CMD /app/wildfly/bin/standalone.sh -b=0.0.0.0 -bmanagement=0.0.0.0 & sh /resources/check-deploy-files.sh & sleep 10s && sh /resources/wait-for-server.sh && tail -f /app/wildfly/standalone/log/server.log

