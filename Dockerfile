FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
# RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
# COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
# USER k8s-pipeline
# ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]