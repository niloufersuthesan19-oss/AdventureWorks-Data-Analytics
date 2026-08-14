CREATE VIEW dbo.vw_SalesPerformance AS
SELECT
    s.OrderDate,
    YEAR(s.OrderDate) AS SalesYear,
    MONTH(s.OrderDate) AS SalesMonth,
    DATENAME(MONTH, s.OrderDate) AS MonthName,
    s.OrderNumber,
    s.ProductKey,
    p.ProductName,
    ps.SubcategoryName,
    pc.CategoryName,
    s.CustomerKey,
    s.TerritoryKey,
    s.OrderQuantity,
    p.ProductPrice,
    p.ProductCost,

    s.OrderQuantity * p.ProductPrice AS Revenue,

    s.OrderQuantity * p.ProductCost AS Cost,

    s.OrderQuantity * (p.ProductPrice - p.ProductCost) AS GrossProfit,

    (s.OrderQuantity * p.ProductPrice)
        - (s.OrderQuantity * p.ProductCost) AS Profit

FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
INNER JOIN dbo.DimProductSubcategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey;


