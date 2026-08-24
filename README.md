# cars-api

API REST de carros desenvolvida em **Java 17 + Spring Boot**, com acesso a banco de dados
**MySQL**, documentação **Swagger/OpenAPI**, configuração por **profiles** (`default` e `prd`)
e empacotamento/execução via **Docker**.

| Recurso | Link |
| --- | --- |
| GitHub | https://github.com/GiovanniSguizzardi/cars-api |
| Docker Hub | https://hub.docker.com/r/ogibas/cars-api |
| Imagem | `ogibas/cars-api:latest` |

## Sumário

1. [Stack](#stack)
2. [Executando a partir da imagem do Docker Hub](#executando-a-partir-da-imagem-do-docker-hub)
3. [Variáveis de ambiente](#variáveis-de-ambiente)
4. [Swagger / OpenAPI](#swagger--openapi)
5. [Profiles](#profiles)
6. [Rotas da API](#rotas-da-api)
7. [Executando com docker compose](#executando-com-docker-compose)
8. [Executando localmente sem Docker](#executando-localmente-sem-docker)
9. [Build da imagem a partir do código-fonte](#build-da-imagem-a-partir-do-código-fonte)
10. [Estrutura do projeto](#estrutura-do-projeto)

## Stack

- Java 17
- Spring Boot (Spring Web MVC + Spring Data JPA)
- MySQL 8
- springdoc-openapi (Swagger UI)
- Maven
- Docker / Docker Hub

## Executando a partir da imagem do Docker Hub

> A aplicação **não cria** o banco de dados nem as tabelas no profile `prd`.
> Por isso o passo 2 cria o schema no MySQL antes de subir a API.

### 1. Baixar a imagem

```bash
docker pull ogibas/cars-api:latest
```

### 2. Subir um MySQL e criar o schema

Crie a rede e o banco:

```bash
docker network create cars-net

docker run -d --name cars-api-mysql --network cars-net \
  -e MYSQL_ROOT_PASSWORD=root_pwd \
  -e MYSQL_DATABASE=api \
  -p 3306:3306 \
  mysql:8.0
```

Aguarde alguns segundos e crie as tabelas (o script está em [`db/init-prd.sql`](db/init-prd.sql)):

```bash
docker exec -i cars-api-mysql mysql -uroot -proot_pwd < db/init-prd.sql
```

<details>
<summary>Sem clonar o repositório? Crie as tabelas com este comando único</summary>

```bash
docker exec -i cars-api-mysql mysql -uroot -proot_pwd -e "
CREATE DATABASE IF NOT EXISTS api;
USE api;
CREATE TABLE IF NOT EXISTS honda (
  id BIGINT NOT NULL AUTO_INCREMENT,
  modelo_carros VARCHAR(100) NOT NULL,
  ano_carros VARCHAR(100) NOT NULL,
  potencia_carros VARCHAR(100) NOT NULL,
  cor_carros VARCHAR(100) NOT NULL,
  nome_ex_dono_carros VARCHAR(100) NULL,
  PRIMARY KEY (id)) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS renault (
  id BIGINT NOT NULL AUTO_INCREMENT,
  modelo_carros VARCHAR(100) NOT NULL,
  ano_carros VARCHAR(100) NOT NULL,
  potencia_carros VARCHAR(100) NOT NULL,
  cor_carros VARCHAR(100) NOT NULL,
  nome_ex_dono_carros VARCHAR(100) NULL,
  PRIMARY KEY (id)) ENGINE=InnoDB;"
```

</details>

### 3. Executar a aplicação

```bash
docker run -d --name cars-api-app --network cars-net \
  -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prd \
  -e DB_URL="jdbc:mysql://cars-api-mysql:3306/api" \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=root_pwd \
  ogibas/cars-api:latest
```

O comando acima já contempla:

- **mapeamento da porta 8080** → `-p 8080:8080`
- **configuração do profile** → `-e SPRING_PROFILES_ACTIVE=prd`
- **variáveis de ambiente de conexão** → `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`

### 4. Verificar

```bash
docker logs -f cars-api-app          # acompanhar a inicialização
curl http://localhost:8080/api/v1/honda
```

Swagger UI: <http://localhost:8080/>

### 5. Parar e remover

```bash
docker rm -f cars-api-app cars-api-mysql
docker network rm cars-net
```

## Variáveis de ambiente

| Variável | Obrigatória | Padrão na imagem | Descrição |
| --- | --- | --- | --- |
| `SPRING_PROFILES_ACTIVE` | Não | `prd` | Profile de execução: `prd` ou `default`. |
| `DB_URL` | **Sim** (profile `prd`) | — | URL JDBC do MySQL. Ex.: `jdbc:mysql://cars-api-mysql:3306/api` |
| `DB_USERNAME` | **Sim** (profile `prd`) | — | Usuário do banco de dados. Ex.: `root` |
| `DB_PASSWORD` | **Sim** (profile `prd`) | — | Senha do banco de dados. Ex.: `root_pwd` |
| `JAVA_OPTS` | Não | *(vazio)* | Opções extras da JVM. Ex.: `-Xmx512m` |

> No profile `default` a conexão é fixa (`jdbc:mysql://localhost:3306/api`) e as três
> variáveis `DB_*` são ignoradas — esse profile é destinado ao desenvolvimento local.

## Swagger / OpenAPI

Com a aplicação em execução:

| Recurso | URL |
| --- | --- |
| Swagger UI | <http://localhost:8080/> |
| Especificação OpenAPI (JSON) | <http://localhost:8080/v3/api-docs> |

O Swagger fica disponível nos dois profiles (`default` e `prd`).

## Profiles

A aplicação possui dois profiles de execução:

### `default` — desenvolvimento local

Arquivo: [`src/main/resources/application.properties`](src/main/resources/application.properties)

- Conexão fixa com `jdbc:mysql://localhost:3306/api?createDatabaseIfNotExist=true`
- `spring.jpa.hibernate.ddl-auto=update` → **o banco e as tabelas são criados automaticamente**
- `spring.jpa.show-sql=true` (SQL no console)

Execução:

```bash
./mvnw spring-boot:run
```

### `prd` — produção

Arquivo: [`src/main/resources/application-prd.properties`](src/main/resources/application-prd.properties)

- Conexão vinda **exclusivamente de variáveis de ambiente** (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`)
- A URL **não** usa `createDatabaseIfNotExist`
- `spring.jpa.hibernate.ddl-auto=none` e `spring.jpa.generate-ddl=false` → **o Hibernate não cria nem altera tabelas**
- `spring.sql.init.mode=never` → nenhum `schema.sql`/`data.sql` é executado
- `spring.jpa.show-sql=false` e `open-in-view=false`

Ou seja: **no profile `prd` a aplicação nunca cria o banco de dados nem as tabelas.**
O schema precisa existir previamente — use [`db/init-prd.sql`](db/init-prd.sql).

Execução:

```bash
java -jar target/app.jar --spring.profiles.active=prd
```

## Rotas da API

Base: `http://localhost:8080/api/v1`

### Honda

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/api/v1/honda` | Lista todos |
| `GET` | `/api/v1/honda/{id}` | Busca por id |
| `POST` | `/api/v1/honda` | Cria novo |
| `PUT` | `/api/v1/honda/{id}` | Atualiza |
| `DELETE` | `/api/v1/honda/{id}` | Remove |

### Renault

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/api/v1/renault` | Lista todos |
| `GET` | `/api/v1/renault/{id}` | Busca por id |
| `POST` | `/api/v1/renault` | Cria novo |
| `PUT` | `/api/v1/renault/{id}` | Atualiza |
| `DELETE` | `/api/v1/renault/{id}` | Remove |

### Extra

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/purosangue` | Retorna um texto sobre a Ferrari Purosangue |

### Exemplo de payload

```json
{
  "modelo": "Civic Type R",
  "ano": "2024",
  "potencia": "320CV",
  "cor": "Branco",
  "exDonoCarro": null
}
```

```bash
curl -X POST http://localhost:8080/api/v1/honda \
  -H "Content-Type: application/json" \
  -d '{"modelo":"Civic Type R","ano":"2024","potencia":"320CV","cor":"Branco"}'
```

> O campo `id` é gerado automaticamente pelo banco e não deve ser enviado no `POST`.

## Executando com docker compose

Forma mais rápida de subir tudo (MySQL + API, já no profile `prd`):

```bash
docker compose up -d --build
```

O `docker-compose.yml` monta o `db/init-prd.sql` em `/docker-entrypoint-initdb.d`, então o
**MySQL** cria o schema na primeira inicialização — a aplicação continua sem criar nada.

Para derrubar tudo (incluindo o volume do banco):

```bash
docker compose down -v
```

## Executando localmente sem Docker

Pré-requisitos: JDK 17+ e um MySQL na porta 3306.

```bash
# 1. Banco
docker run -d --name cars-api-mysql \
  -e MYSQL_ROOT_PASSWORD=root_pwd -e MYSQL_DATABASE=api \
  -p 3306:3306 mysql:8.0

# 2. Aplicação (profile default - cria as tabelas sozinho)
./mvnw spring-boot:run
```

## Build da imagem a partir do código-fonte

O [`Dockerfile`](Dockerfile) usa build multi-stage: o primeiro estágio compila com
`maven:3.9-eclipse-temurin-17` e o segundo copia apenas o `app.jar` para um
`eclipse-temurin:17-jre-alpine`, executado por um usuário sem privilégios de root.

```bash
# Build
docker build -t ogibas/cars-api:latest .

# Publicação no Docker Hub
docker login
docker push ogibas/cars-api:latest
```

## Estrutura do projeto

```
cars-api/
├── Dockerfile                      # build multi-stage da imagem
├── docker-compose.yml              # MySQL + aplicação (profile prd)
├── db/
│   └── init-prd.sql                # schema usado no profile prd
├── pom.xml
└── src/main/
    ├── java/br/com/fiap/cars_api/
    │   ├── Application.java
    │   ├── controller/             # HondaController, RenaultController, FerrariController
    │   ├── model/                  # Honda, Renault (entidades JPA)
    │   └── repository/             # HondaRepository, RenaultRepository
    └── resources/
        ├── application.properties       # profile default
        └── application-prd.properties   # profile prd
```
