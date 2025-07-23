#!/usr/bin/env bash
# setup_and_test.sh
# Detecta o módulo, aplica patches e roda mvn clean test

set -euo pipefail

echo "1) Encontrando o módulo que contém DemoApplication..."
# Procura o arquivo DemoApplication.java, ignora target/
APP_PATH=$(find condomy-backend -type f -name DemoApplication.java \
           -not -path "*/target/*" | head -n1)

if [ -z "$APP_PATH" ]; then
  echo "✖ Não achei DemoApplication.java. Verifique o layout do repo." >&2
  exit 1
fi

# Sobe duas pastas: .../src/main/java/... → módulo raiz
MODULE_ROOT=$(dirname "$(dirname "$APP_PATH")")
echo "   ✓ Módulo detectado em: $MODULE_ROOT"

echo "2) Aplicando @SpringBootApplication em DemoApplication.java"
APP_FILE="$MODULE_ROOT/src/main/java/com/condomy/common_lib/DemoApplication.java"
if ! grep -q "@SpringBootApplication" "$APP_FILE"; then
  sed -i 's|package com.condomy.common_lib;|&\n\nimport org.springframework.boot.autoconfigure.SpringBootApplication;|' "$APP_FILE"
  sed -i 's|public class DemoApplication|@SpringBootApplication\npublic class DemoApplication|' "$APP_FILE"
  echo "   • @SpringBootApplication adicionada"
else
  echo "   • @SpringBootApplication já presente"
fi

echo "3) Aplicando @SpringBootTest em DemoApplicationTests.java"
TEST_FILE="$MODULE_ROOT/src/test/java/com/condomy/common_lib/DemoApplicationTests.java"
if ! grep -q "@SpringBootTest" "$TEST_FILE"; then
  sed -i 's|package com.condomy.common_lib;|&\n\nimport org.springframework.boot.test.context.SpringBootTest;\nimport com.condomy.common_lib.DemoApplication;|' "$TEST_FILE"
  sed -i 's|public class DemoApplicationTests|@SpringBootTest(classes = DemoApplication.class)\npublic class DemoApplicationTests|' "$TEST_FILE"
  echo "   • @SpringBootTest adicionada"
else
  echo "   • @SpringBootTest já presente"
fi

echo "4) Garantindo dependência spring-boot-starter-test e spring-boot-maven-plugin"
POM="$MODULE_ROOT/pom.xml"

# Dependência de teste
if ! grep -q "<artifactId>spring-boot-starter-test</artifactId>" "$POM"; then
  sed -i '/<dependencies>/a\
    <!-- Dependência para testes Spring Boot -->\
    <dependency>\
      <groupId>org.springframework.boot</groupId>\
      <artifactId>spring-boot-starter-test</artifactId>\
      <scope>test</scope>\
    </dependency>' "$POM"
  echo "   • spring-boot-starter-test adicionado"
else
  echo "   • Dependência de teste já existe"
fi

# Plugin Spring Boot
if ! grep -q "<artifactId>spring-boot-maven-plugin</artifactId>" "$POM"; then
  sed -i '/<build>/a\
  <plugins>\
    <plugin>\
      <groupId>org.springframework.boot</groupId>\
      <artifactId>spring-boot-maven-plugin</artifactId>\
    </plugin>\
  </plugins>' "$POM"
  echo "   • spring-boot-maven-plugin adicionado"
else
  echo "   • Plugin spring-boot-maven-plugin já existe"
fi

echo "5) Voltando ao root e rodando todos os testes"
cd condomy-backend
mvn clean test -q

cat <<EOF

✅ Tudo pronto!  

Os testes passaram e você tem:
  • Anotações configuradas  
  • Dependências e plugin de Spring Boot no POM  

Para subir a aplicação, rode dentro do módulo detectado:

  cd $MODULE_ROOT
  mvn spring-boot:run

EOF
