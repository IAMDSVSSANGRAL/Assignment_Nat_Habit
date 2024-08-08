CREATE TABLE cohort (
    customer_id INT,
    order_id INT,
    order_date DATE,
    order_amount DECIMAL(10, 2)
);

INSERT INTO cohort (customer_id, order_id, order_date, order_amount)
VALUES
    (1, 1, '2022-01-10', 100),
    (1, 2, '2022-01-12', 200),
    (1, 3, '2022-02-01', 150),
    (1, 4, '2022-03-01', 200),
    (1, 5, '2022-04-30', 175),
    (2, 6, '2022-01-28', 250),
    (2, 7, '2022-03-13', 400),
    (2, 26, '2022-03-19', 500),
    (3, 8, '2022-01-16', 1000),
    (4, 9, '2022-02-07', 500),
    (5, 10, '2022-02-10', 300),
    (6, 11, '2022-01-19', 400),
    (7, 12, '2022-03-20', 350),
    (8, 13, '2022-03-17', 375),
    (9, 14, '2022-01-15', 400),
    (10, 15, '2022-02-17', 300),
    (10, 16, '2022-04-30', 300),
    (11, 17, '2022-02-08', 200),
    (11, 18, '2022-03-10', 20),
    (11, 19, '2022-04-11', 75),
    (12, 20, '2022-02-10', 250),
    (12, 21, '2022-03-12', 675),
    (13, 22, '2022-03-17', 770),
    (13, 23, '2022-04-03', 900),
    (14, 24, '2022-04-10', 100),
    (15, 25, '2022-04-18', 150);

select * from cohort;

-- TASK 1 Identify the first month of ordering of the customers
SELECT
    customer_id,
    TO_CHAR(DATE_TRUNC('month', MIN(order_date)), 'Mon YYYY') AS first_month_of_ordering
FROM
    cohort
GROUP BY
    customer_id
ORDER BY
	customer_id;


WITH FirstOrder AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS first_month_of_ordering
    FROM
        cohort
    GROUP BY
        customer_id
),
SubsequentOrders AS (
    SELECT
        c.customer_id
    FROM
        cohort o
    JOIN
        FirstOrder c
    ON
        o.customer_id = c.customer_id
    WHERE
        DATE_TRUNC('month', o.order_date) > c.first_month_of_ordering
    GROUP BY
        c.customer_id
)
SELECT
    f.customer_id,
    TO_CHAR(f.first_month_of_ordering, 'Mon YYYY') AS first_month_of_ordering,
    CASE
        WHEN s.customer_id IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS placed_order_in_subsequent_months
FROM
    FirstOrder f
LEFT JOIN
    SubsequentOrders s
ON
    f.customer_id = s.customer_id
ORDER BY
    f.customer_id;


-- task 2 - part_1
WITH FirstOrderMonth AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS acquisition_month
    FROM
        cohort
    GROUP BY
        customer_id
)
SELECT
    TO_CHAR(acquisition_month, 'Mon YYYY') AS acquisition_month,
    COUNT(DISTINCT customer_id) AS unique_customers_acquired
FROM
    FirstOrderMonth
GROUP BY
    acquisition_month;


-- task 2 - part_2
WITH FirstOrderMonth AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS acquisition_month
    FROM
        cohort
    GROUP BY
        customer_id
),
SubsequentOrders AS (
    SELECT
        f.customer_id
    FROM
        cohort o
    JOIN
        FirstOrderMonth f
    ON
        o.customer_id = f.customer_id
    WHERE
        DATE_TRUNC('month', o.order_date) > f.acquisition_month
    GROUP BY
        f.customer_id
)
SELECT
    COUNT(DISTINCT s.customer_id) AS customers_with_subsequent_orders
FROM
    SubsequentOrders s;


-- task 3  - pattern formation

WITH FirstOrderMonth AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS acquisition_month
    FROM
        cohort
    GROUP BY
        customer_id
),
SubsequentOrders AS (
    SELECT
        f.customer_id,
        f.acquisition_month AS m1,
        DATE_TRUNC('month', o.order_date) AS subsequent_month
    FROM
        cohort o
    JOIN
        FirstOrderMonth f
    ON
        o.customer_id = f.customer_id
    WHERE
        DATE_TRUNC('month', o.order_date) > f.acquisition_month
),
MonthCounts AS (
    SELECT
        f.acquisition_month AS m1,
        COUNT(DISTINCT CASE WHEN s.subsequent_month = f.acquisition_month + INTERVAL '1 month' THEN s.customer_id END) AS M2,
        COUNT(DISTINCT CASE WHEN s.subsequent_month = f.acquisition_month + INTERVAL '2 month' THEN s.customer_id END) AS M3
    FROM
        FirstOrderMonth f
    LEFT JOIN
        SubsequentOrders s
    ON
        f.customer_id = s.customer_id
    GROUP BY
        f.acquisition_month
)
SELECT
    TO_CHAR(m1, 'Mon YYYY') AS Month,
    COUNT(DISTINCT f.customer_id) AS M1,
    COALESCE(mc.M2, 0) AS M2,
    COALESCE(mc.M3, 0) AS M3
FROM
    FirstOrderMonth f
LEFT JOIN
    MonthCounts mc
ON
    f.acquisition_month = mc.m1
GROUP BY
    m1, mc.M2, mc.M3







