# SQL Server Column Search Toolkit

Stored procedure para localizar colunas em múltiplos bancos do SQL Server utilizando T-SQL e SQL dinâmico.

---

# Objetivo

Este projeto foi criado para auxiliar administradores de banco de dados na localização rápida de colunas em diferentes databases da instância SQL Server.

A procedure percorre todos os bancos ONLINE da instância e retorna:

- Banco
- Schema
- Tabela
- Coluna

Ideal para:
- troubleshooting
- análise de estrutura
- impacto de alterações
- discovery de dados
- auditoria técnica

---

# Tecnologias Utilizadas

- Microsoft SQL Server
- T-SQL
- Dynamic SQL

---

# Estrutura do Projeto

```txt
sqlserver-column-search/
│
├── README.md
├── procedures/
│   └── sp_search_columns.sql
│
```

---

# Funcionalidades

- Busca colunas em múltiplos bancos
- Ignora databases do sistema
- Filtra apenas databases ONLINE
- Utiliza SQL dinâmico
- Consolida resultados em tabela temporária
- Ordena resultados automaticamente

---

# Stored Procedure

## Nome

```sql
sp_search_columns
```

---

# Como utilizar

## Executar busca por coluna

```sql
EXEC sp_search_columns 'cnpj'
```

---

## Exemplo de busca

```sql
EXEC sp_search_columns 'email'
```

---

# Resultado Esperado

| Banco | Esquema | Tabela | Coluna |
|---|---|---|---|
| ERP | dbo | clientes | email |
| CRM | sales | usuarios | email |

---

# Código Principal

```sql
CREATE PROCEDURE sp_search_columns
(
    @ColumnName VARCHAR(100)
)
AS
BEGIN

    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#Resultados') IS NOT NULL
        DROP TABLE #Resultados;

    CREATE TABLE #Resultados
    (
        Banco   VARCHAR(100),
        Esquema VARCHAR(100),
        Tabela  VARCHAR(100),
        Coluna  VARCHAR(100)
    );

    DECLARE @NomeDB SYSNAME;
    DECLARE @SQL NVARCHAR(MAX);

    DECLARE db_cursor CURSOR FOR

    SELECT name
    FROM sys.databases
    WHERE state_desc = 'ONLINE'
      AND database_id > 4;

    OPEN db_cursor;

    FETCH NEXT FROM db_cursor INTO @NomeDB;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @SQL = '
        INSERT INTO #Resultados
        SELECT
            ''' + @NomeDB + ''',
            TABLE_SCHEMA,
            TABLE_NAME,
            COLUMN_NAME
        FROM ' + QUOTENAME(@NomeDB) + '.INFORMATION_SCHEMA.COLUMNS
        WHERE COLUMN_NAME LIKE @SearchColumn;
        ';

        EXEC sp_executesql
            @SQL,
            N''@SearchColumn VARCHAR(100)'',
            @SearchColumn = ''%' + @ColumnName + '%'';

        FETCH NEXT FROM db_cursor INTO @NomeDB;
    END;

    CLOSE db_cursor;
    DEALLOCATE db_cursor;

    SELECT *
    FROM #Resultados
    ORDER BY Banco, Tabela;

    DROP TABLE #Resultados;

END;
GO
```

---

# Casos de Uso

## Encontrar coluna específica

Exemplo:
- CPF
- EMAIL
- ID_CLIENTE
- CNPJ

---

## Avaliar impacto de alteração

Antes de:
- alterar tipo de dado
- remover coluna
- criar índices
- migrar estrutura

---

## Auditoria de ambientes

Localizar rapidamente:
- tabelas relacionadas
- estruturas duplicadas
- nomenclaturas inconsistentes

---

# Melhorias Futuras

- Busca de valores em tabelas
- Busca de procedures
- Busca de triggers
- Exportação CSV
- Logs de execução
- Filtro por schema
- Interface web em Python

Tecnologias futuras:
- :contentReference[oaicite:1]{index=1}

---

# Como Executar

## 1. Abrir SQL Server Management Studio

Ferramenta:
- :contentReference[oaicite:2]{index=2}

---

## 2. Executar o script da procedure

Arquivo:

```txt
procedures/sp_search_columns.sql
```

---

## 3. Executar pesquisa

```sql
EXEC sp_search_columns 'telefone'
```

---

