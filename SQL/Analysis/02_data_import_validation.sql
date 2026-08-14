USE AdventureWorks_Portfolio;


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

BULK INSERT dbo.DimCalendar
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Calendar Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.DimCustomer
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Customer Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);


BULK INSERT dbo.DimProductCategory
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Product Categories Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);


BULK INSERT dbo.DimProduct
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Product Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);


BULK INSERT dbo.DimProductSubCategory
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Product Subcategories Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.DimTerritory
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Territory Lookup.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.FactReturns
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Returns Data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);


SELECT 'DimCalendar' AS TableName, COUNT(*) AS RecordCount
FROM dbo.DimCalendar

UNION ALL

SELECT 'DimCustomer', COUNT(*)
FROM dbo.DimCustomer

UNION ALL

SELECT 'DimProductCategory', COUNT(*)
FROM dbo.DimProductCategory

UNION ALL

SELECT 'DimProductSubcategory', COUNT(*)
FROM dbo.DimProductSubcategory

UNION ALL

SELECT 'DimProduct', COUNT(*)
FROM dbo.DimProduct

UNION ALL

SELECT 'DimTerritory', COUNT(*)
FROM dbo.DimTerritory;

BULK INSERT dbo.FactSales
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Sales Data 2020.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

SELECT COUNT(*) AS SalesRecords
FROM dbo.FactSales;

CREATE TABLE StgSales (
    OrderDate VARCHAR(50),
    StockDate VARCHAR(50),
    OrderNumber VARCHAR(50),
    ProductKey VARCHAR(50),
    CustomerKey VARCHAR(50),
    TerritoryKey VARCHAR(50),
    OrderLineItem VARCHAR(50),
    OrderQuantity VARCHAR(50)
);

BULK INSERT dbo.StgSales
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Sales Data 2020.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

-- Check row count
SELECT COUNT(*) AS SalesRecords
FROM dbo.StgSales;

-- Check for missing values
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN OrderDate IS NULL OR OrderDate = '' THEN 1 ELSE 0 END) AS MissingOrderDate,
    SUM(CASE WHEN ProductKey IS NULL OR ProductKey = '' THEN 1 ELSE 0 END) AS MissingProductKey,
    SUM(CASE WHEN CustomerKey IS NULL OR CustomerKey = '' THEN 1 ELSE 0 END) AS MissingCustomerKey,
    SUM(CASE WHEN TerritoryKey IS NULL OR TerritoryKey = '' THEN 1 ELSE 0 END) AS MissingTerritoryKey,
    SUM(CASE WHEN OrderQuantity IS NULL OR OrderQuantity = '' THEN 1 ELSE 0 END) AS MissingQuantity
FROM dbo.StgSales;

-- Preview the data
SELECT TOP 10 *
FROM dbo.StgSales;


INSERT INTO dbo.FactSales
(
    OrderDate,
    StockDate,
    OrderNumber,
    ProductKey,
    CustomerKey,
    TerritoryKey,
    OrderLineItem,
    OrderQuantity
)
SELECT
    TRY_CONVERT(DATE, OrderDate),
    TRY_CONVERT(DATE, StockDate),
    OrderNumber,
    TRY_CONVERT(INT, ProductKey),
    TRY_CONVERT(INT, CustomerKey),
    TRY_CONVERT(INT, TerritoryKey),
    TRY_CONVERT(INT, OrderLineItem),
    TRY_CONVERT(INT, OrderQuantity)
FROM dbo.StgSales;

SELECT COUNT(*) AS InvalidProducts
FROM dbo.FactSales s
LEFT JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
WHERE p.ProductKey IS NULL;

SELECT COUNT(*) AS InvalidCustomers
FROM dbo.FactSales s
LEFT JOIN dbo.DimCustomer c
    ON s.CustomerKey = c.CustomerKey
WHERE c.CustomerKey IS NULL;

SELECT COUNT(*) AS InvalidTerritories
FROM dbo.FactSales s
LEFT JOIN dbo.DimTerritory t
    ON s.TerritoryKey = t.SalesTerritoryKey
WHERE t.SalesTerritoryKey IS NULL;

TRUNCATE TABLE dbo.StgSales;

BULK INSERT dbo.StgSales
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Sales Data 2021.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT COUNT(*) AS SalesRecords
FROM dbo.StgSales;

INSERT INTO dbo.FactSales
(
    OrderDate,
    StockDate,
    OrderNumber,
    ProductKey,
    CustomerKey,
    TerritoryKey,
    OrderLineItem,
    OrderQuantity
)
SELECT
    TRY_CONVERT(DATE, OrderDate),
    TRY_CONVERT(DATE, StockDate),
    OrderNumber,
    TRY_CONVERT(INT, ProductKey),
    TRY_CONVERT(INT, CustomerKey),
    TRY_CONVERT(INT, TerritoryKey),
    TRY_CONVERT(INT, OrderLineItem),
    TRY_CONVERT(INT, OrderQuantity)
FROM dbo.StgSales;

SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    COUNT(*) AS TotalSalesRecords
FROM dbo.FactSales;

TRUNCATE TABLE dbo.StgSales;

BULK INSERT dbo.StgSales
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Sales Data 2022.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT
    SUM(CASE WHEN OrderDate IS NULL OR OrderDate = '' THEN 1 ELSE 0 END) AS MissingOrderDate,
    SUM(CASE WHEN ProductKey IS NULL OR ProductKey = '' THEN 1 ELSE 0 END) AS MissingProductKey,
    SUM(CASE WHEN CustomerKey IS NULL OR CustomerKey = '' THEN 1 ELSE 0 END) AS MissingCustomerKey,
    SUM(CASE WHEN TerritoryKey IS NULL OR TerritoryKey = '' THEN 1 ELSE 0 END) AS MissingTerritoryKey,
    SUM(CASE WHEN OrderQuantity IS NULL OR OrderQuantity = '' THEN 1 ELSE 0 END) AS MissingQuantity
FROM dbo.StgSales;

INSERT INTO dbo.FactSales
(
    OrderDate,
    StockDate,
    OrderNumber,
    ProductKey,
    CustomerKey,
    TerritoryKey,
    OrderLineItem,
    OrderQuantity
)
SELECT
    TRY_CONVERT(DATE, OrderDate),
    TRY_CONVERT(DATE, StockDate),
    OrderNumber,
    TRY_CONVERT(INT, ProductKey),
    TRY_CONVERT(INT, CustomerKey),
    TRY_CONVERT(INT, TerritoryKey),
    TRY_CONVERT(INT, OrderLineItem),
    TRY_CONVERT(INT, OrderQuantity)
FROM dbo.StgSales;

SELECT
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    COUNT(*) AS TotalSalesRecords
FROM dbo.FactSales;

SELECT
    YEAR(OrderDate) AS SalesYear,
    COUNT(*) AS SalesRecords,
    SUM(OrderQuantity) AS TotalUnits
FROM dbo.FactSales
GROUP BY YEAR(OrderDate)
ORDER BY SalesYear;

CREATE TABLE StgReturns (
    ReturnDate VARCHAR(50),
    TerritoryKey VARCHAR(50),
    ProductKey VARCHAR(50),
    ReturnQuantity VARCHAR(50)
);
BULK INSERT dbo.StgReturns
FROM 'C:\Users\nilou\OneDrive\Desktop\SSMS Datafile\AdventureWorks Returns Data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT COUNT(*) AS ReturnRecords
FROM dbo.StgReturns;

INSERT INTO dbo.FactReturns
(
    ReturnDate,
    TerritoryKey,
    ProductKey,
    ReturnQuantity
)
SELECT
    TRY_CONVERT(DATE, ReturnDate),
    TRY_CONVERT(INT, TerritoryKey),
    TRY_CONVERT(INT, ProductKey),
    TRY_CONVERT(INT, ReturnQuantity)
FROM dbo.StgReturns;
GO
