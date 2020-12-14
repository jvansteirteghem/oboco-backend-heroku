## Stage 1 : build with maven builder image with native capabilities
FROM ubuntu:18.04 AS build

RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install gcc zlib1g-dev build-essential wget libjpeg-dev

RUN wget https://github.com/graalvm/mandrel/releases/download/mandrel-20.3.0.0.Beta2/mandrel-java11-linux-amd64-20.3.0.0.Beta2.tar.gz -P /tmp
RUN tar xf /tmp/mandrel-java11-linux-amd64-20.3.0.0.Beta2.tar.gz -C /opt
RUN ln -s /opt/mandrel-java11-20.3.0.0.Beta2 /opt/mandrel-java11

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
COPY application.properties /usr/src/oboco/src/main/resources
COPY oboco-backend/src/non-packaged-resources/lib-native/turbojpeg/linux/amd64/libturbojpeg.so /usr/java/packages/lib/libturbojpeg.so
RUN mvn -f /usr/src/oboco/pom.xml -Pnative clean package

## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal

RUN microdnf update
RUN microdnf install wget zip

RUN mkdir "/usr/share/oboco" \
&& mkdir "/usr/share/oboco/data" \
&& mkdir "/tmp/oboco"

RUN mkdir "/tmp/oboco/Pepper and Carrot" \
&& mkdir "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight" \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight/00.jpg" https://www.peppercarrot.com/0_sources/ep01_Potion-of-Flight/low-res/en_Pepper-and-Carrot_by-David-Revoy_E01P00.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight/01.jpg" https://www.peppercarrot.com/0_sources/ep01_Potion-of-Flight/low-res/en_Pepper-and-Carrot_by-David-Revoy_E01P01.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight/02.jpg" https://www.peppercarrot.com/0_sources/ep01_Potion-of-Flight/low-res/en_Pepper-and-Carrot_by-David-Revoy_E01P02.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight/03.jpg" https://www.peppercarrot.com/0_sources/ep01_Potion-of-Flight/low-res/en_Pepper-and-Carrot_by-David-Revoy_E01P03.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight/04.jpg" https://www.peppercarrot.com/0_sources/ep01_Potion-of-Flight/low-res/en_Pepper-and-Carrot_by-David-Revoy_E01P04.jpg \
&& mkdir "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions" \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/00.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P00.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/01.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P01.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/02.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P02.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/03.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P03.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/04.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P04.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/05.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P05.jpg \
&& wget -O "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions/06.jpg" https://www.peppercarrot.com/0_sources/ep02_Rainbow-potions/low-res/en_Pepper-and-Carrot_by-David-Revoy_E02P06.jpg \
&& mkdir "/usr/share/oboco/data/Pepper and Carrot" \
&& zip -r "/usr/share/oboco/data/Pepper and Carrot/Episode 1 - The Potion of Flight.zip" "/tmp/oboco/Pepper and Carrot/Episode 1 - The Potion of Flight" \
&& zip -r "/usr/share/oboco/data/Pepper and Carrot/Episode 2 - Rainbow Potions.zip" "/tmp/oboco/Pepper and Carrot/Episode 2 - Rainbow Potions"

RUN rm -rf "/tmp/oboco"

RUN mkdir "/usr/local/oboco"

WORKDIR /usr/local/oboco
COPY --from=build /usr/src/oboco/target/*-runner /usr/local/oboco/application
COPY --from=build /usr/src/oboco/target/application.properties /usr/local/oboco/application.properties
COPY --from=build /usr/src/oboco/target/user.properties /usr/local/oboco/user.properties
COPY --from=build /usr/src/oboco/target/data /usr/local/oboco/data
COPY --from=build /usr/src/oboco/target/data.csv /usr/local/oboco/data.csv
COPY --from=build /usr/src/oboco/target/logs /usr/local/oboco/logs
COPY --from=build /usr/src/oboco/target/lib-native /usr/local/oboco/lib-native

COPY application.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/application.sh

# set up permissions for user `1001`
RUN chmod 775 /usr/local/oboco /usr/local/oboco/application \
  && chown -R 1001 /usr/local/oboco \
  && chmod -R "g+rwX" /usr/local/oboco \
  && chown -R 1001:root /usr/local/oboco

EXPOSE 8080
USER 1001

CMD ["bash","/usr/local/bin/application.sh"]