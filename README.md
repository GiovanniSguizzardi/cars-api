# cars-api

API de carros feita em Spring Boot com MySQL.

---

## Como rodar

### 1. Subir o banco de dados com Docker

```bash
docker-compose up -d
```

Ou sem o docker-compose:

```bash
docker run -d --name cars-api-mysql -e MYSQL_ROOT_PASSWORD=root_pwd -e MYSQL_DATABASE=api -p 3306:3306 mysql:8.0
```

### 2. Rodar a aplicação

```bash
./mvnw spring-boot:run
```

A aplicação sobe na porta **8080**.

---

## Swagger

Acesse a documentação em: `http://localhost:8080/`

---

## Rotas

- `/api/v1/honda` — GET, POST, PUT, DELETE
- `/api/v1/renault` — GET, POST, PUT, DELETE
