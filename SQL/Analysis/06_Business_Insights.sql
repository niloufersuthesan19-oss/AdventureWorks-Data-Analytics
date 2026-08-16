USE AdventureWorks_Portfolio;
GO
-- Top 10 Products by Gross Profit

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
        / NULLIF(
            SUM(s.OrderQuantity * p.ProductPrice),
            0
        ) * 100,
        2
    ) AS GrossMarginPct
FROM dbo.FactSales s
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
GROUP BY
    p.ProductKey,
    p.ProductName
ORDER BY GrossProfit DESC;