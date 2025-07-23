#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# scripts/scaffold-backend.sh
# Gera multimódulo Spring Boot condomy-backend:
# – pom pai
# – common-lib, auth-service, condo-service, resident-service, billing-service
# Usamos ZIP + unzip para não depender de tar no Windows.
# ------------------------------------------------------------------------------
set -e

echo "� Iniciando scaffold multimódulo condomy-backend..."

# 1) Cria o POM pai (só agrupa módulos)
cat > pom.xml << 'POM'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.condomy</groupId>
  <artifactId>condomy-backend</artifactId>
  <version>1.0.0-SNAPSHOT</version>
  <packaging>pom</packaging>
  <modules>
    <module>common-lib</module>
    <module>auth-service</module>
    <module>condo-service</module>
    <module>resident-service</module>
    <module>billing-service</module>
  </modules>
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-dependencies</artifactId>
        <version>3.1.0</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
</project>
POM
echo "✅ pom.xml pai criado"

# 2) Lista de módulos
modules=(common-lib auth-service condo-service resident-service billing-service)

# 3) Remove pastas antigas (se existirem)
rm -rf "${modules[@]}"

# 4) Loop para gerar cada módulo via Spring Initializr
for svc in "${modules[@]}"; do
  echo "� Criando módulo $svc …"
  mkdir -p "$svc"
  
  # Baixa ZIP (insecure -k ignora problemas de certificado)
  curl -k "https://start.spring.io/starter.zip?\
type=maven-project&language=java&groupId=com.condomy&artifactId=$svc\
&dependencies=web,security,data-jpa,validation" -o "$svc.zip"
  
  # Descompacta no diretório do módulo
  unzip -q "$svc.zip" -d "$svc"
  rm "$svc.zip"
  
  echo "✔ Módulo $svc pronto"
done

# 5) Compila todos os módulos para garantir que está tudo certo
echo "� Compilando tudo com mvn clean install …"
mvn clean install -q

echo "� Scaffold multimódulo concluído com sucesso!"
