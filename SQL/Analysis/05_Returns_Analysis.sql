USE AdventureWorks_Portfolio;
GO
-- Overall Return Rate

WITH SalesTotals AS
(
    SELECT
        SUM(OrderQuantity) AS TotalUnitsSold
    FROM dbo.FactSales
),
ReturnTotals AS
(
    SELECT
        SUM(ReturnQuantity) AS TotalUnitsReturned
    FROM dbo.FactReturns
)
SELECT
    TotalUnitsSold,
    TotalUnitsReturned,
    ROUND(
        CAST(TotalUnitsReturned AS DECIMAL(18,2))
        / NULLIF(TotalUnitsSold, 0) * 100,
        2
    ) AS ReturnRatePct
FROM SalesTotals
CROSS JOIN ReturnTotals;


-- Return Rate by Year

WITH SalesByYear AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(OrderQuantity) AS UnitsSold
    FROM dbo.FactSales
    GROUP BY YEAR(OrderDate)
),
ReturnsByYear AS
(
    SELECT
        YEAR(ReturnDate) AS ReturnYear,
        SUM(ReturnQuantity) AS UnitsReturned
    FROM dbo.FactReturns
    GROUP BY YEAR(ReturnDate)
)
SELECT
    s.SalesYear,
    s.UnitsSold,
    COALESCE(r.UnitsReturned, 0) AS UnitsReturned,
    ROUND(
        CAST(COALESCE(r.UnitsReturned, 0) AS DECIMAL(18,2))
        / NULLIF(s.UnitsSold, 0) * 100,
        2
    ) AS ReturnRatePct
FROM SalesByYear s
LEFT JOIN ReturnsByYear r
    ON s.SalesYear = r.ReturnYear
ORDER BY s.SalesYear;


-- Product Return Rate

WITH ProductSales AS
(
    SELECT
        ProductKey,
        SUM(OrderQuantity) AS UnitsSold
    FROM dbo.FactSales
    GROUP BY ProductKey
),
ProductReturns AS
(
    SELECT
        ProductKey,
        SUM(ReturnQuantity) AS UnitsReturned
    FROM dbo.FactReturns
    GROUP BY ProductKey
)
SELECT TOP 10
    p.ProductKey,
    p.ProductName,
    ps.UnitsSold,
    COALESCE(pr.UnitsReturned, 0) AS UnitsReturned,
    ROUND(
        CAST(COALESCE(pr.UnitsReturned, 0) AS DECIMAL(18,2))
        / NULLIF(ps.UnitsSold, 0) * 100,
        2
    ) AS ReturnRatePct
FROM ProductSales ps
INNER JOIN dbo.DimProduct p
    ON ps.ProductKey = p.ProductKey
LEFT JOIN ProductReturns pr
    ON ps.ProductKey = pr.ProductKey
ORDER BY ReturnRatePct DESC;


-- Return Rate by Product Category

WITH CategorySales AS
(
    SELECT
        pc.CategoryName,
        SUM(s.OrderQuantity) AS UnitsSold
    FROM dbo.FactSales s
    INNER JOIN dbo.DimProduct p
        ON s.ProductKey = p.ProductKey
    INNER JOIN dbo.DimProductSubcategory ps
        ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory pc
        ON ps.ProductCategoryKey = pc.ProductCategoryKey
    GROUP BY
        pc.CategoryName
),
CategoryReturns AS
(
    SELECT
        pc.CategoryName,
        SUM(r.ReturnQuantity) AS UnitsReturned
    FROM dbo.FactReturns r
    INNER JOIN dbo.DimProduct p
        ON r.ProductKey = p.ProductKey
    INNER JOIN dbo.DimProductSubcategory ps
        ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory pc
        ON ps.ProductCategoryKey = pc.ProductCategoryKey
    GROUP BY
        pc.CategoryName
)
SELECT
    s.CategoryName,
    s.UnitsSold,
    COALESCE(r.UnitsReturned, 0) AS UnitsReturned,
    ROUND(
        CAST(COALESCE(r.UnitsReturned, 0) AS DECIMAL(18,2))
        / NULLIF(s.UnitsSold, 0) * 100,
        2
    ) AS ReturnRatePct
FROM CategorySales s
LEFT JOIN CategoryReturns r
    ON s.CategoryName = r.CategoryName
ORDER BY ReturnRatePct DESC;