# cars-api

API REST de carros desenvolvida em **Java 17 + Spring Boot**, com acesso a banco de dados
**SQL Server** via **Spring Data JPA**, documentação **Swagger/OpenAPI** e configuração por
**profiles** (`default` e `prd`).

Repositório: https://github.com/GiovanniSguizzardi/cars-api

## Sumário

1. [Stack](#stack)
2. [Configurando a conexão com o SQL Server](#configurando-a-conexão-com-o-sql-server)
3. [Executando a aplicação](#executando-a-aplicação)
4. [Variáveis de ambiente](#variáveis-de-ambiente)
5. [Profiles](#profiles)
6. [Rotas da API](#rotas-da-api)
7. [Testando a API](#testando-a-api)
8. [Swagger / OpenAPI](#swagger--openapi)
9. [Estrutura do projeto](#estrutura-do-projeto)

## Stack

- Java 17
- Spring Boot (Spring Web MVC + Spring Data JPA / Hibernate)
- Microsoft SQL Server (driver `com.microsoft.sqlserver:mssql-jdbc`)
- springdoc-openapi (Swagger UI)
- Maven

## Configurando a conexão com o SQL Server

### Dados de conexão padrão

| Item | Valor |
| --- | --- |
| Servidor / host | `localhost` |
| Porta | `1433` |
| Banco de dados | `api` |
| Usuário | `sa` |
| Senha | `1q2w3e4R@` |
| URL JDBC | `jdbc:sqlserver://localhost:1433;databaseName=api;encrypt=false;trustServerCertificate=true` |
| Driver | `com.microsoft.sqlserver.jdbc.SQLServerDriver` |

Esses mesmos dados podem ser usados para conectar no banco com uma ferramenta gráfica
(SSMS, Azure Data Studio, DBeaver) e conferir os registros gravados pela API.

> `encrypt=false;trustServerCertificate=true` evitam erro de certificado em um SQL Server local
> com certificado autoassinado. Em um SQL Server remoto com certificado válido, use
> `encrypt=true` e remova o `trustServerCertificate`.

### Onde a conexão é configurada

- **Profile `default`** → valores fixos em
  [`src/main/resources/application.properties`](src/main/resources/application.properties):

  ```properties
  spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=api;encrypt=false;trustServerCertificate=true
  spring.datasource.username=sa
  spring.datasource.password=1q2w3e4R@
  spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver
  ```

  Para apontar para outro SQL Server (remoto, outro usuário, outra senha), altere essas linhas.

- **Profile `prd`** → valores vindos das variáveis de ambiente `DB_URL`, `DB_USERNAME` e
  `DB_PASSWORD` (veja [Variáveis de ambiente](#variáveis-de-ambiente)).

### Criando o banco de dados `api`

O SQL Server **não** cria o banco automaticamente pela URL de conexão. O banco `api` precisa
existir antes da primeira execução. Execute no SSMS / Azure Data Studio, ou pelo `sqlcmd`:

```sql
IF DB_ID('api') IS NULL CREATE DATABASE api;
```

```bash
sqlcmd -S localhost -U sa -P "1q2w3e4R@" -C -Q "IF DB_ID('api') IS NULL CREATE DATABASE api"
```

- No profile `default` basta o banco existir: **as tabelas o Hibernate cria sozinho**.
- No profile `prd` as tabelas também precisam existir: execute o script completo
  [`db/init-prd.sql`](db/init-prd.sql), que cria o banco, as tabelas e insere dados de exemplo:

  ```bash
  sqlcmd -S localhost -U sa -P "1q2w3e4R@" -C -i db/init-prd.sql
  ```

## Executando a aplicação

Pré-requisitos: **JDK 17+** e um **SQL Server** acessível (local ou remoto) com o banco `api`
criado (veja a seção anterior).

### Profile `default` (desenvolvimento)

```bash
# Linux / macOS / Git Bash
./mvnw spring-boot:run

# Windows (PowerShell / CMD)
mvnw.cmd spring-boot:run
```

A API sobe em <http://localhost:8080>.

### Profile `prd`

```bash
# 1. Gerar o artefato
./mvnw clean package -DskipTests

# 2. Definir as variáveis de conexão (exemplo em PowerShell)
$env:DB_URL="jdbc:sqlserver://localhost:1433;databaseName=api;encrypt=false;trustServerCertificate=true"
$env:DB_USERNAME="sa"
$env:DB_PASSWORD="1q2w3e4R@"

# 3. Executar
java -jar target/app.jar --spring.profiles.active=prd
```

## Variáveis de ambiente

Usadas apenas no profile `prd`:

| Variável | Obrigatória | Descrição |
| --- | --- | --- |
| `DB_URL` | **Sim** | URL JDBC do SQL Server. Ex.: `jdbc:sqlserver://localhost:1433;databaseName=api;encrypt=false;trustServerCertificate=true` |
| `DB_USERNAME` | **Sim** | Usuário do banco de dados. Ex.: `sa` |
| `DB_PASSWORD` | **Sim** | Senha do banco de dados. Ex.: `1q2w3e4R@` |

> No profile `default` a conexão é fixa no `application.properties` e essas variáveis são ignoradas.

## Profiles

### `default` — desenvolvimento local

Arquivo: [`src/main/resources/application.properties`](src/main/resources/application.properties)

- Conexão fixa com o SQL Server em `localhost:1433`, banco `api`
- `spring.jpa.hibernate.ddl-auto=update` → **as tabelas são criadas/atualizadas automaticamente**
  (o banco `api` precisa existir)
- `spring.jpa.database-platform=org.hibernate.dialect.SQLServerDialect`
- `spring.jpa.show-sql=true` (SQL no console)

### `prd` — produção

Arquivo: [`src/main/resources/application-prd.properties`](src/main/resources/application-prd.properties)

- Conexão vinda **exclusivamente de variáveis de ambiente** (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`)
- `spring.jpa.hibernate.ddl-auto=none` e `spring.jpa.generate-ddl=false` → **o Hibernate não cria nem altera tabelas**
- `spring.sql.init.mode=never` → nenhum `schema.sql`/`data.sql` é executado
- `spring.jpa.show-sql=false` e `open-in-view=false`

Ou seja: **no profile `prd` a aplicação nunca cria o banco de dados nem as tabelas.**
O schema precisa existir previamente — use [`db/init-prd.sql`](db/init-prd.sql).

## Rotas da API

Base: `http://localhost:8080/api/v1`

### Honda (tabela `honda`)

| Método | Rota | Descrição | Resposta |
| --- | --- | --- | --- |
| `GET` | `/api/v1/honda` | Lista todos | `200` |
| `GET` | `/api/v1/honda/{id}` | Busca por id | `200` / `404` |
| `POST` | `/api/v1/honda` | Cria novo | `201` |
| `PUT` | `/api/v1/honda/{id}` | Atualiza | `200` / `404` |
| `DELETE` | `/api/v1/honda/{id}` | Remove | `204` |

### Renault (tabela `renault`)

| Método | Rota | Descrição | Resposta |
| --- | --- | --- | --- |
| `GET` | `/api/v1/renault` | Lista todos | `200` |
| `GET` | `/api/v1/renault/{id}` | Busca por id | `200` / `404` |
| `POST` | `/api/v1/renault` | Cria novo | `201` |
| `PUT` | `/api/v1/renault/{id}` | Atualiza | `200` / `404` |
| `DELETE` | `/api/v1/renault/{id}` | Remove | `204` |

### Extra

| Método | Rota | Descrição |
| --- | --- | --- |
| `GET` | `/purosangue` | Retorna um texto sobre a Ferrari Purosangue (não acessa o banco) |

### Modelo de dados

As entidades JPA [`Honda`](src/main/java/br/com/fiap/cars_api/model/Honda.java) e
[`Renault`](src/main/java/br/com/fiap/cars_api/model/Renault.java) são mapeadas para as tabelas
`honda` e `renault`, ambas com a mesma estrutura:

| Campo JSON | Coluna no SQL Server | Tipo | Obrigatório |
| --- | --- | --- | --- |
| `id` | `id` | `BIGINT IDENTITY` (gerado pelo banco) | — |
| `modelo` | `modelo_carros` | `VARCHAR(100)` | Sim |
| `ano` | `ano_carros` | `VARCHAR(100)` | Sim |
| `potencia` | `potencia_carros` | `VARCHAR(100)` | Sim |
| `cor` | `cor_carros` | `VARCHAR(100)` | Sim |
| `exDonoCarro` | `nome_ex_dono_carros` | `VARCHAR(100)` | Não |

Exemplo de payload:

```json
{
  "modelo": "Civic Type R",
  "ano": "2024",
  "potencia": "320CV",
  "cor": "Branco",
  "exDonoCarro": null
}
```

> O campo `id` é gerado automaticamente pelo banco e não deve ser enviado no `POST`.

## Testando a API

Roteiro completo de CRUD (troque `honda` por `renault` para testar a outra tabela):

```bash
# Inserir
curl -X POST http://localhost:8080/api/v1/honda \
  -H "Content-Type: application/json" \
  -d '{"modelo":"Civic Type R","ano":"2024","potencia":"320CV","cor":"Branco"}'

# Listar todos
curl http://localhost:8080/api/v1/honda

# Buscar por id
curl http://localhost:8080/api/v1/honda/1

# Alterar
curl -X PUT http://localhost:8080/api/v1/honda/1 \
  -H "Content-Type: application/json" \
  -d '{"modelo":"Civic Type R","ano":"2025","potencia":"330CV","cor":"Preto"}'

# Excluir
curl -X DELETE http://localhost:8080/api/v1/honda/1
```

> No PowerShell use `curl.exe` (em vez de `curl`), ou teste direto pelo [Swagger UI](#swagger--openapi).

### Conferindo os dados no SQL Server

```sql
USE api;
SELECT * FROM honda;
SELECT * FROM renault;
```

## Swagger / OpenAPI

Com a aplicação em execução:

| Recurso | URL |
| --- | --- |
| Swagger UI | <http://localhost:8080/> |
| Especificação OpenAPI (JSON) | <http://localhost:8080/v3/api-docs> |

O Swagger fica disponível nos dois profiles (`default` e `prd`) e permite testar todos os
endpoints pelo navegador.

## Estrutura do projeto

```
cars-api/
├── db/
│   └── init-prd.sql                # schema T-SQL (banco api, tabelas honda/renault)
├── pom.xml                         # dependências (inclui mssql-jdbc)
└── src/main/
    ├── java/br/com/fiap/cars_api/
    │   ├── Application.java
    │   ├── controller/             # HondaController, RenaultController, FerrariController
    │   ├── model/                  # Honda, Renault (entidades JPA)
    │   └── repository/             # HondaRepository, RenaultRepository (Spring Data JPA)
    └── resources/
        ├── application.properties       # profile default
        └── application-prd.properties   # profile prd
```
