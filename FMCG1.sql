create database fmcg1;
Use fmcg1;

-- creating tables

CREATE TABLE products_master (product_id INT PRIMARY KEY,product_name VARCHAR(100),category VARCHAR(50),sub_category VARCHAR(50),brand VARCHAR(50),pack_size VARCHAR(20),mrp DECIMAL(10,2),cost_price DECIMAL(10,2),launch_date DATE,sku VARCHAR(50),gst_pct INT);
CREATE TABLE stores_master (store_id INT PRIMARY KEY,store_name VARCHAR(100),city VARCHAR(50),state VARCHAR(50),store_type VARCHAR(50),area_sqft INT,opening_date DATE,owner VARCHAR(100),channel VARCHAR(50),latitude DECIMAL(10,6),longitude DECIMAL(10,6));
CREATE TABLE customers_master (customer_id INT PRIMARY KEY,customer_name VARCHAR(100),city VARCHAR(50),age INT,gender CHAR(1),membership_type VARCHAR(20),join_date DATE,total_purchases INT,email VARCHAR(100),phone VARCHAR(15),loyalty_points INT);
CREATE TABLE suppliers_master (supplier_id INT PRIMARY KEY,supplier_name VARCHAR(100),contact_person VARCHAR(100),phone VARCHAR(15),email VARCHAR(100),country VARCHAR(50),lead_time_days INT,on_time_delivery_pct INT,quality_rating DECIMAL(3,1),last_delivery_date DATE,preferred VARCHAR(5));
CREATE TABLE promotions (promo_id INT PRIMARY KEY,promo_name VARCHAR(100),product_id INT,start_date DATE,end_date DATE,discount_pct INT,promo_cost DECIMAL(12,2),incremental_sales DECIMAL(12,2),channel VARCHAR(50),target_segment VARCHAR(50),FOREIGN KEY (product_id) REFERENCES products_master(product_id));
CREATE TABLE sales_reps (sales_rep_id INT PRIMARY KEY,rep_name VARCHAR(100),region VARCHAR(50),phone VARCHAR(15),email VARCHAR(100));
CREATE TABLE sales_transactions (sale_id INT PRIMARY KEY,sale_date DATE,product_id INT,store_id INT,quantity INT,unit_price DECIMAL(10,2),discount_pct INT,total_amount DECIMAL(12,2),invoice_no VARCHAR(50),payment_type VARCHAR(20),customer_id INT,sale_timestamp DATETIME,promo_id INT NULL,gst_pct INT,gst_amount DECIMAL(10,2),unit_cost DECIMAL(10,2),cost_total DECIMAL(12,2),profit DECIMAL(12,2),distributor_id INT,batch_no VARCHAR(50),mfg_date DATE,exp_date DATE,sales_rep_id INT,return_flag VARCHAR(5),channel_type VARCHAR(50),
    FOREIGN KEY (product_id) REFERENCES products_master(product_id),
    FOREIGN KEY (store_id) REFERENCES stores_master(store_id),
    FOREIGN KEY (customer_id) REFERENCES customers_master(customer_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id),
    FOREIGN KEY (sales_rep_id) REFERENCES sales_reps(sales_rep_id));


-- **File path saved the CSV files in one folder**
-- Products Master
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Products_Master.csv' 
INTO TABLE products_master 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- store_master
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Store_Master.csv' 
INTO TABLE stores_master 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- customers_master
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Customer_Master.csv' 
INTO TABLE customers_master 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- suppliers_master-- error
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Supplier_Management.csv' 
INTO TABLE suppliers_master 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- promotions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Promotions.csv' 
INTO TABLE promotions 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- sales_reps 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Sales_Reps.csv' 
INTO TABLE sales_reps 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '\"' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- sales_transactions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/FMCG/Sales_Transactions.csv' 
INTO TABLE sales_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@sale_id, @sale_date, @product_id, @store_id, @quantity,
 @unit_price, @discount_pct, @total_amount, @invoice_no,
 @payment_type, @customer_id, @sale_timestamp, @promo_id,
 @gst_pct, @gst_amount, @unit_cost, @cost_total, @profit,
 @distributor_id, @batch_no, @mfg_date, @exp_date,
 @sales_rep_id, @return_flag, @channel_type)
SET sale_id = @sale_id,sale_date = @sale_date,product_id = @product_id,store_id = @store_id,quantity = @quantity,unit_price = @unit_price,discount_pct = @discount_pct,total_amount = @total_amount,invoice_no = @invoice_no,payment_type = @payment_type,customer_id = @customer_id,sale_timestamp = @sale_timestamp,promo_id = NULLIF(@promo_id,''),gst_pct = @gst_pct,gst_amount = @gst_amount,unit_cost = @unit_cost,cost_total = @cost_total,profit = @profit,distributor_id = @distributor_id,batch_no = @batch_no,mfg_date = @mfg_date,exp_date = @exp_date,sales_rep_id = @sales_rep_id,return_flag = IF(@return_flag='TRUE','1','0'),channel_type = @channel_type;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------




-- KPIs


-- Total Sales, Quantity, Profit, Margin %

SELECT
ROUND(SUM(total_amount), 0) AS total_sales,
SUM(quantity) AS total_quantity,
ROUND(SUM(profit), 0) AS gross_profit,
ROUND((SUM(profit) / SUM(total_amount)) * 100, 0) AS gross_margin_pct
FROM sales_transactions
WHERE return_flag = 0;

-- Gross Sales vs COGS

SELECT
ROUND(SUM(total_amount), 0) AS gross_sales,
ROUND(SUM(cost_total), 0) AS cogs
FROM sales_transactions
WHERE return_flag = 0;

-- Average Selling Price & Avg Unit Cost

SELECT
ROUND(SUM(total_amount) / SUM(quantity), 0) AS avg_selling_price,
ROUND(SUM(cost_total) / SUM(quantity), 0) AS avg_unit_cost
FROM sales_transactions
WHERE return_flag = 0;

-- Net Sales Revenue by Channel Type
SELECT
channel_type,
ROUND(SUM(total_amount), 0) AS net_sales
FROM sales_transactions
WHERE return_flag = 0
GROUP BY channel_type;

-- Top 10 Products by Revenue
SELECT
p.category,
ROUND(SUM(t.total_amount), 0) AS net_sales
FROM sales_transactions t
JOIN products_master p
ON t.product_id = p.product_id
WHERE t.return_flag = 0
GROUP BY p.category
ORDER BY net_sales DESC;

-- Top 10 Fast-Moving Items
SELECT
p.product_name,
SUM(t.quantity) AS quantity_sold
FROM sales_transactions t
JOIN products_master p
ON t.product_id = p.product_id
WHERE t.return_flag = 0
GROUP BY p.product_name
ORDER BY quantity_sold DESC
LIMIT 10;

-- Sales Rep Performance
SELECT
sr.rep_name,
ROUND(SUM(t.total_amount), 0) AS sales
FROM sales_transactions t
JOIN sales_reps sr
ON t.sales_rep_id = sr.sales_rep_id
WHERE t.return_flag = 0
GROUP BY sr.rep_name
ORDER BY sales DESC;

-- Net Revenue Before & After GST
SELECT
ROUND(SUM(total_amount - gst_amount), 0) AS net_revenue_before_gst,
ROUND(SUM(total_amount), 0) AS net_revenue_after_gst
FROM sales_transactions
WHERE return_flag = 0;