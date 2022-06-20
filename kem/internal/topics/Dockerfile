FROM jorgerojasdev/kafka-topics-creator:latest
COPY '*.yml' /usr/ktc/src/main/resources
WORKDIR /usr/ktc
RUN mvn clean install
ENTRYPOINT ["mvn", "compile", "exec:java"]