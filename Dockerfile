## Stage 1 : build with maven builder image with native capabilities
FROM ubuntu:18.04 AS build

RUN apt-get clean
RUN apt-get autoclean
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install build-essential libz-dev zlib1g-dev wget libfreetype6-dev

RUN wget https://github.com/graalvm/mandrel/releases/download/mandrel-21.3.0.0-Final/mandrel-java11-linux-amd64-21.3.0.0-Final.tar.gz -P /tmp
RUN tar xf /tmp/mandrel-java11-linux-amd64-21.3.0.0-Final.tar.gz -C /opt
RUN ln -s /opt/mandrel-java11-21.3.0.0-Final /opt/mandrel-java11

ENV JAVA_HOME=/opt/mandrel-java11
ENV GRAALVM_HOME=/opt/mandrel-java11
ENV PATH=${JAVA_HOME}/bin:${PATH}

RUN wget https://www-eu.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp
RUN tar xf /tmp/apache-maven-3.6.3-bin.tar.gz -C /opt
RUN ln -s /opt/apache-maven-3.6.3 /opt/maven

ENV M2_HOME=/opt/maven
ENV MAVEN_HOME=/opt/maven
ENV PATH=${M2_HOME}/bin:${PATH}

RUN mvn --version

COPY oboco-backend/pom.xml /usr/src/oboco/
RUN mvn -f /usr/src/oboco/pom.xml -B de.qaware.maven:go-offline-maven-plugin:1.2.5:resolve-dependencies
COPY oboco-backend/src /usr/src/oboco/src
RUN sed -i "s/quarkus\.datasource\.db\-kind\=.*/quarkus\.datasource\.db\-kind\=postgresql/" /usr/src/oboco/src/main/resources/application.properties \
 && sed -i "s/quarkus\.datasource\.username\=.*/quarkus\.datasource\.username\=/" /usr/src/oboco/src/main/resources/application.properties \
 && sed -i "s/quarkus\.datasource\.password\=.*/quarkus\.datasource\.password\=/" /usr/src/oboco/src/main/resources/application.properties \
 && sed -i "s/quarkus\.datasource\.jdbc\.url\=.*/quarkus\.datasource\.jdbc\.url\=/" /usr/src/oboco/src/main/resources/application.properties
RUN mvn -f /usr/src/oboco/pom.xml -Pnative clean package

## Stage 2 : build dependencies
FROM registry.access.redhat.com/ubi8/ubi-minimal as build-dependencies

RUN microdnf update
RUN microdnf install freetype fontconfig wget zip jq

RUN mkdir "/usr/share/oboco" \
&& mkdir "/usr/share/oboco/data" \
&& mkdir "/tmp/oboco"

COPY data.sh /tmp/oboco/data.sh

RUN sh /tmp/oboco/data.sh

RUN rm -rf "/tmp/oboco"

## Stage 3 : create the docker final image
FROM quay.io/quarkus/quarkus-micro-image:1.0

COPY --from=build-dependencies \
   /lib64/libfreetype.so.6 \
   /lib64/libgcc_s.so.1 \
   /lib64/libbz2.so.1 \
   /lib64/libpng16.so.16 \
   /lib64/libm.so.6 \
   /lib64/libbz2.so.1 \
   /lib64/libexpat.so.1 \
   /lib64/libuuid.so.1 \
   /lib64/

COPY --from=build-dependencies \
   /usr/lib64/libfontconfig.so.1 \
   /usr/lib64/

COPY --from=build-dependencies \
    /usr/share/fonts /usr/share/fonts

COPY --from=build-dependencies \
    /usr/share/fontconfig /usr/share/fontconfig

COPY --from=build-dependencies \
    /usr/lib/fontconfig /usr/lib/fontconfig

COPY --from=build-dependencies \
     /etc/fonts /etc/fonts

RUN mkdir "/usr/share/oboco"
COPY --from=build-dependencies /usr/share/oboco /usr/share/oboco

RUN mkdir "/usr/local/oboco"

WORKDIR /usr/local/oboco
COPY --from=build /usr/src/oboco/target/*-runner /usr/local/oboco/application
COPY --from=build /usr/src/oboco/target/data /usr/local/oboco/data
COPY --from=build /usr/src/oboco/target/data.csv /usr/local/oboco/data.csv
COPY --from=build /usr/src/oboco/target/logs /usr/local/oboco/logs
COPY --from=build /usr/src/oboco/target/lib-native /usr/local/oboco/lib-native

COPY application.properties /usr/local/oboco/application.properties
COPY data.properties /usr/local/oboco/data.properties

COPY application.sh /usr/local/bin/application.sh
RUN chmod 777 /usr/local/bin/application.sh

# set up permissions for user `1001`
RUN chmod 775 /usr/local/oboco /usr/local/oboco/application \
  && chown -R 1001 /usr/local/oboco \
  && chmod -R "g+rwX" /usr/local/oboco \
  && chown -R 1001:root /usr/local/oboco

EXPOSE 8080
USER 1001

CMD ["bash", "/usr/local/bin/application.sh"]