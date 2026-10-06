-- ===========================================================================
-- Script de criacao do schema (SQL Server / T-SQL) para o profile prd.
--
-- No profile prd a aplicacao NAO cria o banco nem as tabelas
-- (ddl-auto=none). Este script deve ser executado UMA VEZ no SQL Server
-- antes de subir a aplicacao. Ele e idempotente (pode ser reexecutado).
--
--   sqlcmd -S localhost -U sa -P "1q2w3e4R@" -C -i db/init-prd.sql
-- ===========================================================================

IF DB_ID('api') IS NULL
    CREATE DATABASE api;
GO

USE api;
GO

IF OBJECT_ID('dbo.honda', 'U') IS NULL
    CREATE TABLE dbo.honda (
        id                  BIGINT       IDENTITY(1,1) NOT NULL,
        modelo_carros       VARCHAR(100) NOT NULL,
        ano_carros          VARCHAR(100) NOT NULL,
        potencia_carros     VARCHAR(100) NOT NULL,
        cor_carros          VARCHAR(100) NOT NULL,
        nome_ex_dono_carros VARCHAR(100) NULL,
        CONSTRAINT pk_honda PRIMARY KEY (id)
    );
GO

IF OBJECT_ID('dbo.renault', 'U') IS NULL
    CREATE TABLE dbo.renault (
        id                  BIGINT       IDENTITY(1,1) NOT NULL,
        modelo_carros       VARCHAR(100) NOT NULL,
        ano_carros          VARCHAR(100) NOT NULL,
        potencia_carros     VARCHAR(100) NOT NULL,
        cor_carros          VARCHAR(100) NOT NULL,
        nome_ex_dono_carros VARCHAR(100) NULL,
        CONSTRAINT pk_renault PRIMARY KEY (id)
    );
GO

-- Dados de exemplo (opcional)
IF NOT EXISTS (SELECT 1 FROM dbo.honda)
    INSERT INTO dbo.honda (modelo_carros, ano_carros, potencia_carros, cor_carros, nome_ex_dono_carros)
    VALUES ('Civic Type R', '2024', '320CV', 'Branco', NULL);

IF NOT EXISTS (SELECT 1 FROM dbo.renault)
    INSERT INTO dbo.renault (modelo_carros, ano_carros, potencia_carros, cor_carros, nome_ex_dono_carros)
    VALUES ('Megane RS', '2022', '300CV', 'Amarelo', NULL);
GO
