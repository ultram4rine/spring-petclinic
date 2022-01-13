FROM maven:3.6.0-jdk-8 AS build
COPY .mvn /home/app/.mvn
COPY src /home/app/src
COPY pom.xml /home/app
COPY mvnw /home/app
WORKDIR "/home/app"
RUN chmod +x mvnw
ENV MAVEN_CONFIG=
RUN ./mvnw spring-javaformat:apply
RUN ./mvnw package

FROM openjdk:8-jdk-alpine
ARG APP_HOME=/usr/share/app
ENV APP_USER=pet
RUN addgroup $APP_USER \
    && adduser -S $APP_USER -G $APP_USER \
    && mkdir -p ${APP_HOME}
COPY --from=build /home/app/target/*.jar ${APP_HOME}/app.jar
RUN chown -R $APP_USER:$APP_USER ${APP_HOME}
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/usr/share/app/app.jar"]
