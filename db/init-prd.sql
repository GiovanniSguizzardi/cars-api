-- ===========================================================================
-- Script de criacao do schema para o profile prd.
--
-- No profile prd a aplicacao NAO cria o banco nem as tabelas
-- (ddl-auto=none). Este script deve ser executado UMA VEZ no MySQL
-- antes de subir o container da aplicacao.
--
--   docker exec -i cars-api-mysql mysql -uroot -proot_pwd < db/init-prd.sql
-- ===========================================================================

CREATE DATABASE IF NOT EXISTS api
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE api;

CREATE TABLE IF NOT EXISTS honda (
    id                  BIGINT       NOT NULL AUTO_INCREMENT,
    modelo_carros       VARCHAR(100) NOT NULL,
    ano_carros          VARCHAR(100) NOT NULL,
    potencia_carros     VARCHAR(100) NOT NULL,
    cor_carros          VARCHAR(100) NOT NULL,
    nome_ex_dono_carros VARCHAR(100) NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS renault (
    id                  BIGINT       NOT NULL AUTO_INCREMENT,
    modelo_carros       VARCHAR(100) NOT NULL,
    ano_carros          VARCHAR(100) NOT NULL,
    potencia_carros     VARCHAR(100) NOT NULL,
    cor_carros          VARCHAR(100) NOT NULL,
    nome_ex_dono_carros VARCHAR(100) NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

-- Dados de exemplo (opcional)
INSERT INTO honda (modelo_carros, ano_carros, potencia_carros, cor_carros, nome_ex_dono_carros)
SELECT 'Civic Type R', '2024', '320CV', 'Branco', NULL
WHERE NOT EXISTS (SELECT 1 FROM honda);

INSERT INTO renault (modelo_carros, ano_carros, potencia_carros, cor_carros, nome_ex_dono_carros)
SELECT 'Megane RS', '2022', '300CV', 'Amarelo', NULL
WHERE NOT EXISTS (SELECT 1 FROM renault);
