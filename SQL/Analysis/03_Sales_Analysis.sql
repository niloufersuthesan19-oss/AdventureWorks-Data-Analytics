---Sales Performance
SELECT
    YEAR(s.OrderDate) AS SalesYear,
    COUNT(DISTINCT s.OrderNumber) AS TotalOrders,
    SUM(s.OrderQuantity) AS UnitsSold,
    SUM(s.OrderQuantity * p.ProductPrice) AS Revenue,
    SUM(s.OrderQuantity * p.ProductCost) AS Cost,
    SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) AS GrossProfit
FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
GROUP BY YEAR(s.OrderDate)
ORDER BY SalesYear;

---Profitability & YoY Growth
WITH YearlySales AS
(
    SELECT
        YEAR(s.OrderDate) AS SalesYear,
        SUM(s.OrderQuantity * p.ProductPrice) AS Revenue,
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)) AS GrossProfit
    FROM dbo.FactSales s
    INNER JOIN dbo.DimProduct p
        ON s.ProductKey = p.ProductKey
    GROUP BY YEAR(s.OrderDate)
)
SELECT
    SalesYear,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ROUND(GrossProfit / NULLIF(Revenue, 0) * 100, 2) AS GrossMarginPct,

    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY SalesYear))
        / NULLIF(LAG(Revenue) OVER (ORDER BY SalesYear), 0) * 100,
        2
    ) AS RevenueYoYPct,

    ROUND(
        (GrossProfit - LAG(GrossProfit) OVER (ORDER BY SalesYear))
        / NULLIF(LAG(GrossProfit) OVER (ORDER BY SalesYear), 0) * 100,
        2
    ) AS GrossProfitYoYPct

FROM YearlySales
ORDER BY SalesYear;

-- Monthly Sales Performance

SELECT
    YEAR(s.OrderDate) AS SalesYear,
    MONTH(s.OrderDate) AS SalesMonth,
    DATENAME(MONTH, s.OrderDate) AS MonthName,
    SUM(s.OrderQuantity) AS UnitsSold,
    ROUND(
        SUM(s.OrderQuantity * p.ProductPrice), 
        2
    ) AS Revenue,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),
        2
    ) AS GrossProfit
FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
GROUP BY
    YEAR(s.OrderDate),
    MONTH(s.OrderDate),
    DATENAME(MONTH, s.OrderDate)
ORDER BY
    SalesYear,
    SalesMonth;

-- Top 10 Products by Revenue

SELECT TOP 10
    p.ProductKey,
    p.ProductName,
    SUM(s.OrderQuantity) AS UnitsSold,
    ROUND(
        SUM(s.OrderQuantity * p.ProductPrice),
        2
    ) AS Revenue,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),
        2
    ) AS GrossProfit,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost))
        / NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0) * 100,
        2
    ) AS GrossMarginPct
FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
GROUP BY
    p.ProductKey,
    p.ProductName
ORDER BY Revenue DESC;

-- Product Category & Subcategory Performance

SELECT
    pc.CategoryName,
    ps.SubcategoryName,
    SUM(s.OrderQuantity) AS UnitsSold,
    ROUND(
        SUM(s.OrderQuantity * p.ProductPrice),
        2
    ) AS Revenue,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),
        2
    ) AS GrossProfit,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost))
        / NULLIF(SUM(s.OrderQuantity * p.ProductPrice), 0) * 100,
        2
    ) AS GrossMarginPct
FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
INNER JOIN dbo.DimProductSubcategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
INNER JOIN dbo.DimProductCategory pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY
    pc.CategoryName,
    ps.SubcategoryName
ORDER BY
    Revenue DESC;

-- Product Category Performance

WITH CategorySales AS
(
    SELECT
        pc.CategoryName,
        SUM(s.OrderQuantity) AS UnitsSold,
        SUM(s.OrderQuantity * p.ProductPrice) AS Revenue,
        SUM(
            s.OrderQuantity * (p.ProductPrice - p.ProductCost)
        ) AS GrossProfit
    FROM dbo.FactSales s
    INNER JOIN dbo.DimProduct p
        ON s.ProductKey = p.ProductKey
    INNER JOIN dbo.DimProductSubcategory ps
        ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    INNER JOIN dbo.DimProductCategory pc
        ON ps.ProductCategoryKey = pc.ProductCategoryKey
    GROUP BY
        pc.CategoryName
)
SELECT
    CategoryName,
    UnitsSold,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(GrossProfit, 2) AS GrossProfit,
    ROUND(
        GrossProfit / NULLIF(Revenue, 0) * 100,
        2
    ) AS GrossMarginPct,
    ROUND(
        Revenue / SUM(Revenue) OVER () * 100,
        2
    ) AS RevenueContributionPct
FROM CategorySales
ORDER BY Revenue DESC;