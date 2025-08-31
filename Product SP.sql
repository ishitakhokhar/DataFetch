USE ProductDB;

CREATE OR ALTER PROCEDURE GenerateDummyProducts
    @TotalProducts INT = 10000
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;

    WHILE @i <= @TotalProducts
    BEGIN
        DECLARE @name NVARCHAR(100);

        -- Pick a random category
        DECLARE @categories TABLE (CategoryName NVARCHAR(50));
        INSERT INTO @categories VALUES ('Laptop'), ('Smartphone'), ('Tablet'), ('Keyboard'), ('Mouse'), ('Headphone'), ('Monitor'), ('Camera'), ('Printer'), ('Speaker');

        DECLARE @rand INT = ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM @categories) + 1;

        SELECT TOP 1 @name = CategoryName + ' ' + CAST(@i AS NVARCHAR(10))
        FROM (
            SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn, CategoryName
            FROM @categories
        ) c
        WHERE rn = @rand;

        -- Insert into Product table
        INSERT INTO Product (ProductName, CreatedAt, ModifiedAt)
        VALUES (@name, GETDATE(), NULL);

        SET @i += 1;
    END
END;
GO


EXEC GenerateDummyProducts @TotalProducts = 1000000;
