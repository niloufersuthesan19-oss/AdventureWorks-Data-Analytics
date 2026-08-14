CREATE VIEW dbo.vw_ReturnPerformance AS
SELECT
    r.ReturnDate,
    YEAR(r.ReturnDate) AS ReturnYear,
    MONTH(r.ReturnDate) AS ReturnMonth,
    DATENAME(MONTH, r.ReturnDate) AS MonthName,

    r.ProductKey,
    p.ProductName,
    pc.CategoryName,
    ps.SubcategoryName,

    r.TerritoryKey,
    r.ReturnQuantity,

    COALESCE(s.UnitsSold, 0) AS UnitsSold,

    CASE
        WHEN COALESCE(s.UnitsSold, 0) = 0 THEN 0
        ELSE
            ROUND(
                CAST(r.ReturnQuantity AS DECIMAL(18,2))
                / s.UnitsSold * 100,
                2
            )
    END AS ReturnRatePct

FROM dbo.FactReturns r

INNER JOIN dbo.DimProduct p
    ON r.ProductKey = p.ProductKey

INNER JOIN dbo.DimProductSubcategory ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

INNER JOIN dbo.DimProductCategory pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

LEFT JOIN
(
    SELECT
        ProductKey,
        SUM(OrderQuantity) AS UnitsSold
    FROM dbo.FactSales
    GROUP BY ProductKey
) s
    ON r.ProductKey = s.ProductKey;