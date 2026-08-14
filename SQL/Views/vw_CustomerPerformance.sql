CREATE VIEW dbo.vw_CustomerPerformance AS
SELECT
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,

    COUNT(DISTINCT s.OrderNumber) AS TotalOrders,

    SUM(s.OrderQuantity) AS UnitsPurchased,

    SUM(s.OrderQuantity * p.ProductPrice) AS Revenue,

    SUM(
        s.OrderQuantity * (p.ProductPrice - p.ProductCost)
    ) AS GrossProfit,

    ROUND(
        SUM(s.OrderQuantity * p.ProductPrice)
        / NULLIF(COUNT(DISTINCT s.OrderNumber), 0),
        2
    ) AS AverageOrderValue,

    ROUND(
        CAST(SUM(s.OrderQuantity) AS DECIMAL(18,2))
        / NULLIF(COUNT(DISTINCT s.OrderNumber), 0),
        2
    ) AS AverageUnitsPerOrder,

    CASE
        WHEN SUM(s.OrderQuantity * p.ProductPrice) >= 10000
            THEN 'High Value'
        WHEN SUM(s.OrderQuantity * p.ProductPrice) >= 5000
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment

FROM dbo.FactSales s

INNER JOIN dbo.DimCustomer c
    ON s.CustomerKey = c.CustomerKey

INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey

GROUP BY
    c.CustomerKey,
    c.FirstName,
    c.LastName;