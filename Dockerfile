FROM adoptopenjdk/openjdk8:alpine-slim
EXPOSE 8080
ARG JAR_FILE=target/*.jar
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
#using run command to create group called pipeline and user k8s-pipeline, then add user k8s-pipeline to group pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
#Using Copy instead of ADD to copy jar file into user home directory
USER k8s-pipeline
#Using k8s-pipeline user instead of root user
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]