CREATE VIEW dbo.vw_ProductPerformance AS
SELECT
    p.ProductKey,
    p.ProductName,
    pc.CategoryName,
    ps.SubcategoryName,

    SUM(s.OrderQuantity) AS UnitsSold,

    SUM(s.OrderQuantity * p.ProductPrice) AS Revenue,

    SUM(s.OrderQuantity * p.ProductCost) AS Cost,

    SUM(
        s.OrderQuantity * (p.ProductPrice - p.ProductCost)
    ) AS GrossProfit,

    ROUND(
        SUM(
            s.OrderQuantity * (p.ProductPrice - p.ProductCost)
        )
        / NULLIF(
            SUM(s.OrderQuantity * p.ProductPrice),
            0
        ) * 100,
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
    p.ProductKey,
    p.ProductName,
    pc.CategoryName,
    ps.SubcategoryName;
