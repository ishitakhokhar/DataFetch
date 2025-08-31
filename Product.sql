CREATE DATABASE ProductDB;
USE ProductDB;

CREATE TABLE Product
(
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedAt DATETIME NULL
);

SELECT COUNT(*) FROM Product;

ALTER PROCEDURE GetProductsWithPaginationAndSearch
    @PageNo INT,
    @PageSize INT,
    @Search NVARCHAR(100) = ''
AS
BEGIN

    DECLARE @Skip INT = (@PageNo - 1) * @PageSize;

    -- Step 1: Select page slice from the full table
    ;WITH PageSlice AS
    (
        SELECT *
        FROM Product
        ORDER BY ProductID
        OFFSET @Skip ROWS
        FETCH NEXT @PageSize ROWS ONLY
    )
    -- Step 2: Apply search only inside this page slice
    SELECT *
    FROM PageSlice
    WHERE (@Search = '' OR ProductName LIKE '%' + @Search + '%')
    ORDER BY ProductID;
END


-- Get first 10 rows, search only within this page
EXEC GetProductsWithPaginationAndSearch @PageNo = 1, @PageSize = 10, @Search = 'Keyboard';
