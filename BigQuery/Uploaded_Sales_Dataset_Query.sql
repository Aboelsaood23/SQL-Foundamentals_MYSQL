
-- ALTER TABALES TO ADD PRIMARY KEYS AND FOREING KEYS 'as i used SandBox free tier i couldn't apply it while uploading data '
-- users table 

ALTER TABLE `Uploaded_Sales_Dataset.Users` 
ADD PRIMARY KEY (id) NOT ENFORCED ; 
-- products table 
ALTER TABLE `Uploaded_Sales_Dataset.Products` 
ADD PRIMARY KEY (id) NOT ENFORCED; 
-- orders table 
ALTER TABLE `Uploaded_Sales_Dataset.Orders`
ADD PRIMARY KEY (id) NOT ENFORCED ; 

ALTER TABLE `Uploaded_Sales_Dataset.Orders`
ADD FOREIGN KEY (user_id) REFERENCES `Uploaded_Sales_Dataset.Users`(id) NOT ENFORCED;

ALTER TABLE `Uploaded_Sales_Dataset.Orders`
ADD FOREIGN KEY (product_id) REFERENCES `Uploaded_Sales_Dataset.Products`(id) NOT ENFORCED;



-- let's check if the schema is correct 
-- let's check oders table as it contain all other foreign keys 
SELECT 
    cols.column_name, 
    cols.data_type,
    keys.constraint_name,
    ref.table_name AS referenced_table_name,
    ref.column_name AS referenced_column_name
FROM `Uploaded_Sales_Dataset.INFORMATION_SCHEMA.COLUMNS` AS cols
LEFT JOIN `Uploaded_Sales_Dataset.INFORMATION_SCHEMA.KEY_COLUMN_USAGE` AS keys
    ON cols.table_name = keys.table_name 
    AND cols.column_name = keys.column_name
LEFT JOIN `Uploaded_Sales_Dataset.INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE` AS ref
    ON keys.constraint_name = ref.constraint_name
    AND keys.table_name != ref.table_name 
WHERE cols.table_name = 'Orders'
ORDER BY cols.ordinal_position;

-- sales,taxes,discounts and revenue by year
WITH ordersdetails AS (
      SELECT 
      o.id, o.tax, 
      EXTRACT (YEAR FROM o.created_at) AS Year_Of_Sales, 
      ROUND((o.quantity*p.price),2) AS Order_Sales,
      ROUND((o.quantity*p.price*(COALESCE(o.`dicount `,0)/100)),2) AS Order_Discount
      FROM `Uploaded_Sales_Dataset.Orders` AS o  LEFT JOIN `Uploaded_Sales_Dataset.Products` AS p 
      ON o.product_id = p.id
    ),
    total_sales AS( 
           SELECT
        Year_Of_Sales,
        COUNT(id) AS Orders_Count ,
        ROUND(SUM(Order_Sales),3) AS Total_Sales,
        ROUND(SUM(Order_Discount),3) AS Total_Discounts,
        ROUND(SUM((Order_Sales-Order_Discount)*(tax/100)),3) AS Total_Taxes,
        ROUND(SUM((Order_Sales-Order_Discount)-((Order_Sales-Order_Discount)*(tax/100))),3) AS Total_Revenue
        FROM ordersdetails 
        GROUP BY Year_Of_Sales  
    ) 
SELECT *
 FROM total_sales
 ORDER BY Year_Of_Sales DESC ; 

--  category analysis , "there is mismatch between data so this results null value category " if we use left join , so i will use inner join 
-- as each order contian only one product we can use the AVG function 
SELECT 
    p.category AS Category, 
    COUNT(o.id) AS Orders_Count, 
    ROUND(SUM(o.quantity*p.price),2) AS Orders_Sales, 
    ROUND(AVG(o.quantity*p.price),2) AS Orders_Average
FROM `Uploaded_Sales_Dataset.Orders` AS o INNER JOIN `Uploaded_Sales_Dataset.Products` AS P 
ON o. product_id = p.id 
GROUP BY Category ; 

-- Prouducst Analysis 
-- same thing to avoid data mismatch we will use INNER JOIN 
SELECT p.title AS Product_Name,
       p.category AS Product_Category, 
       ROUND(SUM(o.quantity*p.price),2) AS Product_Sales,
       COUNT(o.id) AS Product_Orders 
FROM `Uploaded_Sales_Dataset.Orders` AS o INNER JOIN `Uploaded_Sales_Dataset.Products` AS p
ON   o.product_id = p.id 
GROUP BY Product_Name, Product_Category
ORDER BY Product_Sales DESC;  


-- let's get the dead stock"products with lowest seles on the last 90 dayes" 
SELECT p.title As Product_Name , 
       p.category AS Product_Category , 
       Round(SUM(o.quantity*p.price),2) AS Product_Sales 
FROM `Uploaded_Sales_Dataset.Orders` AS o INNER JOIN `Uploaded_Sales_Dataset.Products` AS p 
ON o.product_id = p.id
WHERE o.created_at >= (
    SELECT DATE_SUB(MAX(created_at), INTERVAL  90 DAY)
    FROM `Uploaded_Sales_Dataset.Orders`
                      )
GROUP BY Product_Name , Product_Category 
ORDER BY Product_Sales 
LIMIT 10 ; 


-- users analysis . total sales by user and count of orders 
SELECT  u.`name `  AS User_Name, 
        u.id AS User_Id ,
        COUNT(o.id) AS Orders_Count, 
        ROUND(SUM(o.quantity *p.price)) AS Total_Sales 
FROM `Uploaded_Sales_Dataset.Orders` AS o LEFT JOIN `Uploaded_Sales_Dataset.Users` AS u 
ON o.user_id = u.id  
LEFT JOIN  `Uploaded_Sales_Dataset.Products` AS p ON o.product_id = p.id
GROUP BY User_Name , User_Id 
ORDER BY Total_Sales DESC; 

-- top 3 heighest expensive products by category "USING WINDOW FUNCTIONS"

SELECT * FROM (
   SELECT id , category , title , price , 
ROW_NUMBER () OVER(
    PARTITION BY category 
    ORDER BY price DESC 
) AS products_price_rank

FROM `Uploaded_Sales_Dataset.Products` 
)
WHERE products_price_rank <= 3 ;


-- top  3 customers sales by state "USING WIDOW FUNCTIONS"
WITH Users_Sales    AS (
    SELECT o.user_id ,u.`name `, u.state , 
       ROUND(SUM(o.quantity*p.price),2) AS total_sales
FROM `Uploaded_Sales_Dataset.Orders` AS o LEFT JOIN `Uploaded_Sales_Dataset.Users` AS u  ON o.user_id =u.id 
INNER JOIN `Uploaded_Sales_Dataset.Products` AS p ON o.product_id = p.id
GROUP BY o.user_id, u.`name `, u.state
), Users_Row_Sales AS (
    SELECT * , 
    ROW_NUMBER() OVER
    (
        PARTITION BY state
        ORDER BY total_sales DESC
    ) AS Top_Three 
    FROM Users_Sales
) 
SELECT * FROM Users_Row_Sales 
WHERE Top_Three <= 3
ORDER BY state ;

-- quarter over quarter growth "USING WINDOW FUNCTIONS"
WITH Sales_Quarter AS (
SELECT
    EXTRACT(YEAR FROM o.created_at) AS yr,
    EXTRACT(QUARTER FROM o.created_at) AS qtr, 
    CONCAT ('Q',EXTRACT(QUARTER FROM o.created_at),'_',EXTRACT(YEAR FROM o.created_at)) AS Quarter_Year,
    Round(SUM(o.quantity*p.price),2) AS Total_Sale
FROM `Uploaded_Sales_Dataset.Orders` AS o LEFT JOIN `Uploaded_Sales_Dataset.Products` AS p ON o.product_id = p.id 
GROUP BY Quarter_Year,yr,qtr
ORDER BY 
        EXTRACT(YEAR FROM o.created_at) DESC, 
         EXTRACT(QUARTER FROM o.created_at) DESC
         
                        ),
    Lagged_Table AS (
SELECT *, 
    LAG(Total_Sale,1) OVER(ORDER BY yr,qtr) AS Lagged_Values
FROM     Sales_Quarter
                    )
SELECT Quarter_Year , Total_Sale, 
       ROUND(Total_Sale -Lagged_Values , 2  ) AS Sales_Growth,
       CONCAT(CAST(ROUND(SAFE_DIVIDE((Total_Sale-Lagged_Values),Lagged_Values)*100,2) AS STRING) ,'%') AS Growth_Values
FROM Lagged_Table
ORDER BY yr DESC, qtr DESC;

-- runing total sales by year "USING WINDOW AGGREGATED FUNCTIONS"
WITH Sales_Table AS (
    SELECT 
   EXTRACT (YEAR FROM o.created_at) AS Year_Sales,
   ROUND(SUM(o.quantity*p.price),2) AS Sales
   FROM `Uploaded_Sales_Dataset.Orders` AS o INNER JOIN `Uploaded_Sales_Dataset.Products`     AS p ON o.product_id = p.id
GROUP BY  Year_Sales
ORDER BY Year_Sales ASC 
)
SELECT *,
   SUM(Sales) OVER(

                 ORDER BY Year_Sales ASC
                   )
 FROM Sales_Table ; 
