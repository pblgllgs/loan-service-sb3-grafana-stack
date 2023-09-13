#FROM eclipse-temurin:17
#
#EXPOSE 8080
#
#COPY ./target/app-ci-cd-1.0.0.jar /usr/app
#
#WORKDIR /user/app
#
#ENTRYPOINT ["java", "-jar","app-ci-cd-1.0.0.jar"]


FROM maven:3.8.7-eclipse-temurin-17-alpine@sha256:8592edb5fa55225ae4f2e218d6caf719ebd88ecb56698b563c2b71936544981f AS build
RUN mkdir /project
COPY . /project
WORKDIR /project
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-alpine@sha256:f4766a483f0754930109771aebccb93c6e7a228b1977cf2e3fd49285270a2eb3
RUN apk add dumb-init
RUN mkdir /app
RUN addgroup --system javauser && adduser -S -s /bin/false -G javauser javauser
COPY --from=build /project/target/app-ci-cd-1.0.0.jar /app/app-ci-cd-1.0.0.jar
WORKDIR /app
RUN chown -R javauser:javauser /app
USER javauser
CMD "dumb-init" "java" "-jar" "app-ci-cd-1.0.0.jar"