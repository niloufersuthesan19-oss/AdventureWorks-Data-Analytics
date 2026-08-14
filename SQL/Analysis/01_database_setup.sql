CREATE DATABASE AdventureWorks_Portfolio;
USE AdventureWorks_Portfolio;

-- 1. Calendar
CREATE TABLE DimCalendar (
    Date DATE PRIMARY KEY
);


-- 2. Customer
CREATE TABLE DimCustomer (
    CustomerKey INT PRIMARY KEY,
    Prefix VARCHAR(10),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    BirthDate DATE,
    MaritalStatus VARCHAR(5),
    Gender VARCHAR(5),
    EmailAddress VARCHAR(150),
    AnnualIncome DECIMAL(12,2),
    TotalChildren INT,
    EducationLevel VARCHAR(50),
    Occupation VARCHAR(50),
    HomeOwner VARCHAR(5)
);


-- 3. Product Category
CREATE TABLE DimProductCategory (
    ProductCategoryKey INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);


-- 4. Product Subcategory
CREATE TABLE DimProductSubcategory (
    ProductSubcategoryKey INT PRIMARY KEY,
    SubcategoryName VARCHAR(100),
    ProductCategoryKey INT
);


-- 5. Product
CREATE TABLE DimProduct (
    ProductKey INT PRIMARY KEY,
    ProductSubcategoryKey INT,
    ProductSKU VARCHAR(50),
    ProductName VARCHAR(150),
    ModelName VARCHAR(150),
    ProductDescription NVARCHAR(MAX),
    ProductColor VARCHAR(50),
    ProductSize VARCHAR(20),
    ProductStyle VARCHAR(20),
    ProductCost DECIMAL(12,4),
    ProductPrice DECIMAL(12,2)
);


-- 6. Territory
CREATE TABLE DimTerritory (
    SalesTerritoryKey INT PRIMARY KEY,
    Region VARCHAR(100),
    Country VARCHAR(100),
    Continent VARCHAR(100)
);

-- 7. Sales Fact
CREATE TABLE FactSales (
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATE,
    StockDate DATE,
    OrderNumber VARCHAR(30),
    ProductKey INT,
    CustomerKey INT,
    TerritoryKey INT,
    OrderLineItem INT,
    OrderQuantity INT
);


-- 8. Returns Fact
CREATE TABLE FactReturns (
    ReturnKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    ReturnDate DATE,
    TerritoryKey INT,
    ProductKey INT,
    ReturnQuantity INT
);

-- Product Subcategory → Product Category
ALTER TABLE DimProductSubcategory
ADD CONSTRAINT FK_ProductSubcategory_Category
FOREIGN KEY (ProductCategoryKey)
REFERENCES DimProductCategory(ProductCategoryKey);


-- Product → Product Subcategory
ALTER TABLE DimProduct
ADD CONSTRAINT FK_Product_Subcategory
FOREIGN KEY (ProductSubcategoryKey)
REFERENCES DimProductSubcategory(ProductSubcategoryKey);


-- Sales → Product
ALTER TABLE FactSales
ADD CONSTRAINT FK_Sales_Product
FOREIGN KEY (ProductKey)
REFERENCES DimProduct(ProductKey);


-- Sales → Customer
ALTER TABLE FactSales
ADD CONSTRAINT FK_Sales_Customer
FOREIGN KEY (CustomerKey)
REFERENCES DimCustomer(CustomerKey);


-- Sales → Territory
ALTER TABLE FactSales
ADD CONSTRAINT FK_Sales_Territory
FOREIGN KEY (TerritoryKey)
REFERENCES DimTerritory(SalesTerritoryKey);


-- Returns → Product
ALTER TABLE FactReturns
ADD CONSTRAINT FK_Returns_Product
FOREIGN KEY (ProductKey)
REFERENCES DimProduct(ProductKey);


-- Returns → Territory
ALTER TABLE FactReturns
ADD CONSTRAINT FK_Returns_Territory
FOREIGN KEY (TerritoryKey)
REFERENCES DimTerritory(SalesTerritoryKey);
