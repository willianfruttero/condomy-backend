#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# scripts/scaffold-backend.sh
# Gera multim√≥dulo Spring Boot condomy-backend:
# ‚Äì pom pai
# ‚Äì common-lib, auth-service, condo-service, resident-service, billing-service
# Usamos ZIP + unzip para n√£o depender de tar no Windows.
# ------------------------------------------------------------------------------
set -e

echo "Ì¥ß Iniciando scaffold multim√≥dulo condomy-backend..."

# 1) Cria o POM pai (s√≥ agrupa m√≥dulos)
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
echo "‚úÖ pom.xml pai criado"

# 2) Lista de m√≥dulos
modules=(common-lib auth-service condo-service resident-service billing-service)

# 3) Remove pastas antigas (se existirem)
rm -rf "${modules[@]}"

# 4) Loop para gerar cada m√≥dulo via Spring Initializr
for svc in "${modules[@]}"; do
  echo "Ì≥¶ Criando m√≥dulo $svc ‚Ä¶"
  mkdir -p "$svc"
  
  # Baixa ZIP (insecure -k ignora problemas de certificado)
  curl -k "https://start.spring.io/starter.zip?\
type=maven-project&language=java&groupId=com.condomy&artifactId=$svc\
&dependencies=web,security,data-jpa,validation" -o "$svc.zip"
  
  # Descompacta no diret√≥rio do m√≥dulo
  unzip -q "$svc.zip" -d "$svc"
  rm "$svc.zip"
  
  echo "‚úî M√≥dulo $svc pronto"
done

# 5) Compila todos os m√≥dulos para garantir que est√° tudo certo
echo "Ì∫ß Compilando tudo com mvn clean install ‚Ä¶"
mvn clean install -q

echo "Ìæâ Scaffold multim√≥dulo conclu√≠do com sucesso!"
