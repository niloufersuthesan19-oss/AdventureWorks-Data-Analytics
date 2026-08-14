-- Top 10 Customers by Revenue

SELECT TOP 10
    c.CustomerKey,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    COUNT(DISTINCT s.OrderNumber) AS TotalOrders,
    SUM(s.OrderQuantity) AS UnitsPurchased,
    ROUND(
        SUM(s.OrderQuantity * p.ProductPrice),
        2
    ) AS Revenue,
    ROUND(
        SUM(s.OrderQuantity * (p.ProductPrice - p.ProductCost)),
        2
    ) AS GrossProfit
FROM dbo.FactSales s
INNER JOIN dbo.DimCustomer c
    ON s.CustomerKey = c.CustomerKey
INNER JOIN dbo.DimProduct p
    ON s.ProductKey = p.ProductKey
GROUP BY
    c.CustomerKey,
    c.FirstName,
    c.LastName
ORDER BY Revenue DESC;