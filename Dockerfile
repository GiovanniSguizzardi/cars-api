# ===========================================================================
# Estagio 1 - build do artefato com Maven + JDK 17
# ===========================================================================
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Copia o pom primeiro para aproveitar o cache de dependencias do Docker
COPY pom.xml .
COPY src ./src

# Gera o artefato target/app.jar (finalName=app no pom.xml)
RUN mvn -B -DskipTests clean package

# ===========================================================================
# Estagio 2 - imagem final, apenas com o JRE 17 e o artefato
# ===========================================================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Usuario sem privilegios de root
RUN addgroup -S spring && adduser -S spring -G spring

# Copia o artefato gerado no estagio de build
COPY --from=build /build/target/app.jar /app/app.jar

RUN chown -R spring:spring /app
USER spring

# Profile usado quando nenhum outro e informado no docker run.
# Pode ser sobrescrito com: -e SPRING_PROFILES_ACTIVE=default
ENV SPRING_PROFILES_ACTIVE=prd
ENV JAVA_OPTS=""

# Porta da aplicacao
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE -jar /app/app.jar"]
