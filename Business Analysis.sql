-- Creating the tables to load the data

-- Drop tables if they exist to avoid errors on return
DROP TABLE IF EXISTS warranty;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS category;

-- 1. stores table
CREATE TABLE stores
(
store_id VARCHAR(5) PRIMARY KEY,
store_name VARCHAR (30),
city VARCHAR(25),
country VARCHAR(25)
);

-- 2. category table
CREATE TABLE category
(
category_id VARCHAR(10) PRIMARY KEY,
category_name VARCHAR(20)
);

-- 3. products table
CREATE TABLE products
(
product_id VARCHAR(10) PRIMARY KEY,
product_name VARCHAR (35),
category_id VARCHAR(10),
launch_date date,
price FLOAT,
CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category (category_id)
);

-- 4. sales table
CREATE TABLE sales
(
sale_id VARCHAR(15) PRIMARY KEY,
sale_date DATE,
store_id VARCHAR(10),
product_id VARCHAR(10),
quantity INT,
CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores (store_id),
CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products (product_id)
);

-- 5. warranty table
CREATE TABLE warranty
(
claim_id VARCHAR(10) PRIMARY KEY,
claim_date date,
sale_id VARCHAR(15),
repair_status VARCHAR(15),
CONSTRAINT fk_orders FOREIGN KEY (sale_id) REFERENCES sales (sale_id)
);

------------------------------------------------------------------------




-- Apple Sales one million rows dataset
SELECT *
FROM category;

SELECT *
FROM products;

SELECT *
FROM stores;

SELECT *
FROM sales;
 
SELECT COUNT(*)
FROM sales;

SELECT *
FROM warranty;

--------------------------------------------------------------------------------






--Improving Query Performance

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE product_id = 'P-48'
-- Time it took for this query to execute:
-- "Planning Time: 0.179 ms"   "Execution Time: 2453.909 ms"

-- Creating an index to improve the performance when working with one million rows

CREATE INDEX sales_product_id 
ON sales(product_id)


EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE product_id = 'P-48'
--"Planning Time: 2.711 ms"   "Execution Time: 492.843 ms"
-- Therefore the execution time improved from 2453,909 ms to 492.843 ms

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE store_id = 'ST-63'
-- Time it took for this query to execute:
-- "Planning Time: 0.222 ms"   "Execution Time: 1028.373 ms"

-- creating an index to improve the performance
CREATE INDEX sales_store_id 
ON sales(store_id)

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE store_id = 'ST-63'
--"Planning Time: 0.176 ms"    "Execution Time: 16.169 ms"
-- Therefore the execution time improved from 1028.373 ms to 16.169 ms

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE sale_date = '2022-07-20'
--"Planning Time: 48.411 ms"  "Execution Time: 1135.619 ms"

CREATE INDEX sales_sale_date
ON sales(sale_date)

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE sale_date = '2022-07-20'
--"Planning Time: 2.867 ms"   "Execution Time: 3.278 ms"
-- The execution time improved from 1135.619 ms to 3.278 ms

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------




--Business Queries

-- How many Apple Stores are currently operating in each country?
-- This provides a concise overview of the stores global retail footprint.
SELECT 
	country, 
	COUNT(store_id) total_stores
FROM stores
GROUP BY 1
ORDER BY 2 ;

 
-- What is the total number of units each store has sold?
-- This indicates the sales volume performance across the individual Apple Stores.

SELECT 
	sales.store_id,
	stores.store_name,
	SUM(quantity) as total_units_sold
FROM sales
JOIN stores
ON stores.store_id = sales.store_id
GROUP BY 1, 2
ORDER BY 3 DESC;

-- Let's focus on recent performance. 
-- How many sales transactions were complete specifically in November 2024?

SELECT 
	COUNT(sale_id) as total_sale
FROM sales
WHERE  TO_CHAR(sale_date, 'MM-YYYY') = '11-2024';


-- Regarding customer satisfaction and product reliability, 
-- are there any Apple Stores that have maintained a perfect record with zero warranty claims filed to date?

SELECT 
	COUNT(*) 
FROM stores
WHERE store_id NOT IN (
                        SELECT 
	                       DISTINCT store_id
                        FROM sales 
                        RIGHT JOIN warranty 
                        ON sales.sale_id = warranty.sale_id
						);


-- The efficiency of the warranty process. 
-- What percentage of the total warranty claims are ultimately deemed 'Warranty Void'?



SELECT 
	ROUND
	(COUNT(claim_id)/
	                (SELECT COUNT(*) FROM warranty)::numeric
    *100, 2) as warranty_void_percentage
FROM warranty       
WHERE repair_status = 'Rejected' ;


-- Which Apple Store demonstrated the strongest sales performance in terms of total units sold over the past year? 
-- Other stores can learn from their success.

SELECT
	sales.store_id,
	stores.store_name,
	SUM(sales.quantity)
FROM sales
JOIN stores 
ON sales.store_id = stores.store_id
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1

-- To gauge product diversification and customer appeal, 
-- how many unique Apple products were sold across all stores in the last year?

SELECT
	products.product_name,
	COUNT(DISTINCT sales.product_id)
FROM sales 
JOIN products
ON sales.product_id = products.product_id
WHERE sales.sale_date >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY 1
ORDER BY 2 DESC


-- What is the average price point for products within each of the key product categories? 
-- This will help with pricing strategies.

SELECT
	products.category_id,
	category.category_name,
	AVG(products.price) AS avg_price
FROM products
JOIN category 
ON products.category_id = category.category_id
GROUP BY 1, 2
ORDER BY 3 DESC


-- Looking back, how many warranty claims were filed specifically in the year 2020? 
-- Interested in historical trends.

SELECT  
	COUNT(*) AS warranty_claim
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2020


-- For each Apple Store, can you identify the single day when they achieved their highest sales volume? 
-- Observing peak performance days.

SELECT  *
FROM 
(
         SELECT
		 	store_id,
			TO_CHAR(sale_date, 'Day') as day_name,
			SUM(quantity) as total_units_sold,
			RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) as rank
		FROM sales
		GROUP BY 1, 2
) as t1
WHERE rank = 1


-- Which Apple product in each country, for each year, has consistently been the slowest seller based on total units sold? 
-- Underperforming Stores must be addressed.

WITH product_rank
AS
(
SELECT 
	stores.country,
	products.product_name,
	SUM(sales.quantity) as total_quantity_sold,
	RANK() OVER (PARTITION BY stores.country ORDER BY SUM(sales.quantity)) AS rank
FROM sales
JOIN stores
ON sales.store_id = stores.store_id
JOIN products
ON sales.product_id = products.product_id
GROUP BY 1, 2
)
SELECT *
FROM product_rank
WHERE rank = 1


-- What's the volume of warranty claims that were received within the first 180 days of a product sale? 
-- This is crucial for early product quality assessment.

SELECT 
	COUNT(*)
FROM warranty
LEFT JOIN sales
ON sales.sale_id = warranty.sale_id
WHERE warranty.claim_date - sales.sale_date <= 180


-- Regarding the newest innovations, 
-- how many warranty claims have been filed for products that were launched within the last two years?

SELECT 
	products.product_name,
	COUNT(warranty.claim_id) as num_of_claims,
	COUNT(sales.sale_id) as total_sold
FROM warranty
RIGHT JOIN sales
ON sales.sale_id = warranty.sale_id
JOIN products
ON products.product_id = sales.product_id
WHERE products.launch_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY 1
HAVING COUNT(warranty.claim_id) > 0


-- Interested in seasonality and growth spikes?
-- Showing the specific months over the past three years where the sales in the USA exceeded 5,000 units. 

SELECT
	TO_CHAR(sale_date, 'MM-YYYY') AS month,
	SUM(sales.quantity) AS total_unit_sold
FROM sales
JOIN stores
ON sales.store_id = stores.store_id
WHERE stores.country = 'United States' AND sales.sale_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1
HAVING SUM(sales.quantity) > 5000


-- Potential areas for quality improvement.
-- Which product category has generated the highest number of warranty claims over the last two years? 

SELECT
	category.category_name,
	COUNT(warranty.claim_id) AS total_claims
FROM warranty 
LEFT JOIN sales
ON warranty.sale_id = sales.sale_id
JOIN products
ON products.product_id = sales.product_id
JOIN category
ON category.category_id = products.category_id
WHERE warranty.claim_date >= CURRENT_DATE - INTERVAL '2 year'
GROUP BY 1


-- From a customer experience standpoint, 
-- what is the probability that a customer will file a warranty claim after purchasing a product in each respective country?

SELECT
	country,
	total_units_sold,
	total_claim,
	total_claim::numeric/total_units_sold::numeric * 100 AS risk
FROM
(SELECT 
	stores.country,
	COUNT(sales.quantity) AS total_units_sold,
	COUNT(warranty.claim_id) AS total_claim
FROM sales
JOIN stores
ON sales.store_id = stores.store_id
LEFT JOIN warranty
ON warranty.sale_id = sales.sale_id
GROUP BY 1 ) AS t1
ORDER BY 4 DESC


-- Analyzing the growth trajectory of each Apple Store. 
-- What is the year-over-year sales growth ratio for every store?

WITH yearly_sales
AS
(
SELECT
	sales.store_id,
	stores.store_name,
	EXTRACT(YEAR FROM sale_date) AS year,
	SUM(sales.quantity * products.price) AS total_sale
FROM sales
JOIN products
ON sales.product_id = products.product_id
JOIN stores
ON stores.store_id = sales.store_id
GROUP BY 1, 2, 3
ORDER BY 2, 3
),
growth_ratio
AS
(
SELECT
	store_name,
	year,
	LAG(total_sale, 1) OVER (PARTITION BY store_name ORDER BY year) AS last_year_sale,
	total_sale AS current_year_sale
FROM yearly_sales
)
SELECT
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND(
	(current_year_sale - last_year_sale)::numeric/last_year_sale::numeric * 100,
	3)
	AS growth_ratio
FROM growth_ratio
WHERE last_year_sale IS NOT NULL AND YEAR <> EXTRACT(YEAR FROM CURRENT_DATE)


-- Is there a discernible relationship between the price of the products and the likelihood of a warranty claim? 
-- Show the correlation segmented by price range for products sold in the last five years.

SELECT
	CASE
		WHEN products.price < 500 THEN 'Less Expensive Product'
		WHEN products.price BETWEEN 500 AND 1000 THEN 'Mid Range Product'
		ELSE 'Expensive Product'
	END AS price_segment,
	COUNT(warranty.claim_id) AS total_claim
FROM warranty
LEFT JOIN sales
ON warranty.sale_id = sales.sale_id
JOIN products
ON products.product_id = sales.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1

-- Service and performance: Operational efficiency of the repair process.
-- Which Apple Store has the highest proportion of 'Completed' claims compared to their overall warranty claims filed? 

WITH completed_repair AS
(
SELECT 
	sales.store_id,
	COUNT(warranty.claim_id) AS completed_repairs
FROM sales
RIGHT JOIN warranty 
ON warranty.sale_id = sales.sale_id
WHERE repair_status = 'Completed'
GROUP BY 1
),

total_repaired AS
(
SELECT 
	sales.store_id,
	COUNT(warranty.claim_id) AS total_repaired
FROM sales
RIGHT JOIN warranty 
ON warranty.sale_id = sales.sale_id
GROUP BY 1
)

SELECT
	total_repaired.store_id,
	stores.store_name,
	completed_repair.completed_repairs,
	total_repaired.total_repaired,
	ROUND
	(completed_repair.completed_repairs::numeric/total_repaired.total_repaired::numeric * 100 
	,2) 
	AS percentage_completed_repairs
FROM completed_repair
JOIN total_repaired
ON completed_repair.store_id = total_repaired.store_id
JOIN stores
ON total_repaired.store_id = stores.store_id
ORDER BY percentage_completed_repairs DESC


--A continuous view of the sales performance. 
--The monthly running total of sales for each Apple Store over the past four years, 
--to easily compare trends.

WITH monthly_sales AS
(
SELECT
	store_id,
	EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
	SUM(products.price * sales.quantity) AS total_revenue
FROM sales
JOIN products
ON sales.product_id = products.product_id
GROUP BY 1, 2, 3
ORDER BY 1, 2, 3
)

SELECT
	store_id,
	month,
	year,
	total_revenue,
	SUM(total_revenue) OVER (PARTITION BY store_id ORDER BY year, month) as running_total
FROM monthly_sales


-- Provide a comprehensive analysis of our product sales trends over their lifecycle. 
-- I want to see how sales perform in the initial 0-6 months, then 6-12 months, 12-18 months, and beyond 18 months from launch. 
-- This will inform our product development and marketing strategies.

SELECT
	products.product_name,
	CASE
		WHEN sales.sale_date BETWEEN products.launch_date AND products.launch_date + INTERVAL '6 months' THEN '0-6 months'
		WHEN sales.sale_date BETWEEN products.launch_date + INTERVAL '6 months' AND products.launch_date + INTERVAL '12 months'THEN '6-12 months'
		WHEN sales.sale_date BETWEEN products.launch_date + INTERVAL '12 months' AND products.launch_date + INTERVAL '18 months'THEN '12-18 months'
		ELSE '18 months+'
	END AS product_life_cycle,
	SUM(sales.quantity) AS total_qty_sale
FROM sales
JOIN products
ON sales.product_id = products.product_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC







































































