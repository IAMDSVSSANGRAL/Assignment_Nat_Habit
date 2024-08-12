use nathabitdb;
drop table if exists ordersitems;

create table ordersitems(
order_id int,
customer int,
city_id int,
created_at varchar(20),
delivery_time varchar(20),
undelivered_time varchar(20),
order_type varchar(20),
order_source varchar(20),
order_status varchar(20),
payment_method varchar(20),
discount int,
shipping_amt int,
order_amt int,
payment_charges int,
total_amt varchar(20),
product_id bigint,
variant_id bigint,
ordered_qty	int,
per_unit_price int,
city varchar(30),
pincode int,
state varchar(20));

select * from ordersitems;

select @@secure_file_priv;

LOAD DATA INFILE "C:/ProgramData/MySQL/MYSQL Server 8.0/Uploads/Orders_Items_Data.csv"
INTO TABLE ordersitems
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer, city_id, @created_at, @delivery_time, @undelivered_time, order_type, order_source,
 order_status, payment_method, discount, shipping_amt, order_amt, payment_charges, total_amt, product_id,
 variant_id, ordered_qty, per_unit_price, city, @pincode, state)
SET 
    created_at = NULLIF(@created_at, ''),
    delivery_time = NULLIF(@delivery_time, ''),
    undelivered_time = NULLIF(@undelivered_time, ''),
    pincode = NULLIF(@pincode, '');


select * from ordersitems;

DESCRIBE ordersitems;

ALTER TABLE ordersitems
ADD COLUMN temp_created_at DATE,
ADD COLUMN temp_delivery_time DATE,
ADD COLUMN temp_undelivered_time DATE;

SET SQL_SAFE_UPDATES = 0;


UPDATE ordersitems
SET 
    temp_created_at = STR_TO_DATE(created_at, '%d-%m-%Y'),
    temp_delivery_time = STR_TO_DATE(delivery_time, '%d-%m-%Y'),
    temp_undelivered_time = STR_TO_DATE(undelivered_time, '%d-%m-%Y');
    

ALTER TABLE ordersitems
DROP COLUMN created_at,
DROP COLUMN delivery_time,
DROP COLUMN undelivered_time;

ALTER TABLE ordersitems
CHANGE COLUMN temp_created_at created_at DATE,
CHANGE COLUMN temp_delivery_time delivery_time DATE,
CHANGE COLUMN temp_undelivered_time undelivered_time DATE;

select * from ordersitems;










