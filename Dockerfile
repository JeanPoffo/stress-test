# Multi-stage build para otimizar o tamanho da imagem final
FROM gradle:8.13-jdk21-alpine AS build

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de configuração primeiro (para cache de dependências)
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle/ gradle/

# Baixar dependências (esta camada será cacheada se não houver mudanças nos arquivos de build)
RUN gradle dependencies --no-daemon

# Copiar código fonte
COPY src/ src/

# Build da aplicação
RUN gradle build --no-daemon -x test

# Extrair o JAR construído
RUN mkdir -p build/dependency && \
    cd build/dependency && \
    jar -xf ../libs/*.jar

# Estágio final - runtime
FROM eclipse-temurin:21-jre-alpine

# Instalar dumb-init para melhor gerenciamento de processos
RUN apk add --no-cache dumb-init

# Criar usuário não-root para segurança
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Definir diretório de trabalho
WORKDIR /app

# Copiar dependências e classes em camadas separadas para melhor cache
COPY --from=build /app/build/libs/*.jar app.jar

# Definir usuário não-root
USER appuser

# Configurar variáveis de ambiente com otimizações para JDK 21
ENV JAVA_OPTS="-Xmx512m -Xms256m --enable-preview"

# Expor porta
EXPOSE 8080

# Usar dumb-init e executar com JVM otimizada
ENTRYPOINT ["dumb-init", "--"]
CMD ["java", "-jar", "app.jar"]