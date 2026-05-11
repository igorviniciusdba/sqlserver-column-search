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
            N'@SearchColumn VARCHAR(100)',
            @SearchColumn = '%' + @ColumnName + '%';

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
