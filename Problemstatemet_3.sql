-- Its Sample solution , actual result may vary totally depend on 

WITH OrderDates AS (
  SELECT 
    o.Customer_ID,
    p.Product_Category,
    o.Created_At,
    ROW_NUMBER() OVER (PARTITION BY o.Customer_ID, p.Product_Category ORDER BY o.Created_At) AS order_sequence
  FROM Order_Table o
  JOIN Order_item oi ON o.Order_ID = oi.Order_ID
  JOIN Product_Master p ON oi.Product_ID = p.Product_ID
),
RepeatOrders AS (
  SELECT 
    Customer_ID,
    Product_Category,
    Created_At,
    LAG(Created_At) OVER (PARTITION BY Customer_ID, Product_Category ORDER BY Created_At) AS previous_order_date
  FROM OrderDates
  WHERE order_sequence > 1
)
SELECT 
  Customer_ID,
  Product_Category,
  AVG(DATEDIFF(day, previous_order_date, Created_At)) AS avg_days_to_repeat
FROM RepeatOrders
GROUP BY Customer_ID, Product_Category
ORDER BY avg_days_to_repeat;