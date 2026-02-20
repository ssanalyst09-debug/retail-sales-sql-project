CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    signup_date DATE
);

INSERT INTO customers VALUES
(1,'Ali','Karachi','2023-01-10'),
(2,'Sara','Lahore','2023-02-15'),
(3,'Ahmed','Karachi','2023-03-01'),
(4,'Ayesha','Islamabad','2023-03-20'),
(5,'Bilal','Lahore','2023-04-05');

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price INT
);

INSERT INTO products VALUES
(1,'Laptop','Electronics',150000),
(2,'Mobile','Electronics',80000),
(3,'Shoes','Fashion',5000),
(4,'Watch','Fashion',12000),
(5,'Headphones','Electronics',7000);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(1,1,'2023-05-01',150000),
(2,2,'2023-05-03',80000),
(3,1,'2023-06-01',7000),
(4,3,'2023-06-15',5000),
(5,4,'2023-07-01',12000),
(6,2,'2023-07-10',5000);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_details VALUES
(1,1,1,1),
(2,2,2,1),
(3,3,5,1),
(4,4,3,1),
(5,5,4,1),
(6,6,3,1);

select *
from customers;

select *
from customers
where city= "Lahore";

select *
from productsorder_details
where category= "electronics";

SELECT o.order_id, c.name, o.total_amount
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id;

SELECT o.order_id, p.product_name, p.price
FROM order_details od
JOIN products p on od.product_id = p.product_id
JOIN orders o on od.order_id = o.order_id;

SELECT SUM(total_amount) AS total_revenue
FROM orders;

SELECT customer_id,
SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;

SELECT customer_id,
SUM(total_amount) AS total_spent,
RANK() OVER (ORDER BY SUM(total_amount) DESC) AS rank_position
FROM orders
GROUP BY customer_id;

SELECT order_date,
SUM(total_amount) OVER (ORDER BY order_date) AS running_total
FROM orders;

SELECT customer_id, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id
HAVING SUM(total_amount) > (
    SELECT AVG(total_amount)
    FROM orders
);


SELECT *
FROM orders o
WHERE order_date = (
    SELECT MAX(order_date)
    FROM orders
    WHERE customer_id = o.customer_id
);

WITH CustomerSpending AS (
    SELECT customer_id,
           SUM(total_amount) AS total_spent
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM CustomerSpending
ORDER BY total_spent DESC;


WITH ProductSales AS (
    SELECT p.category,
           p.product_name,
           SUM(od.quantity) AS total_sold,
           ROW_NUMBER() OVER (
               PARTITION BY p.category
               ORDER BY SUM(od.quantity) DESC
           ) AS rn
    FROM products p
    JOIN order_details od
        ON p.product_id = od.product_id
    GROUP BY p.category, p.product_name
)
SELECT *
FROM ProductSales
WHERE rn = 1;

SELECT c.customer_id, c.name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

SELECT c.name,
       SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY lifetime_value DESC;

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS monthly_sales,
    LAG(SUM(total_amount)) OVER (
        ORDER BY DATE_FORMAT(order_date, '%Y-%m')
    ) AS previous_month_sales
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

CREATE VIEW revenue_summary AS
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');

CREATE INDEX idx_customer
ON orders(customer_id);

SELECT 
    c.name,
    c.city,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    od.quantity,
    o.total_amount
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN products p 
    ON od.product_id = p.product_id;
    
    SELECT 
    c.name,
    c.city,
    o.order_id,
    o.order_date,
    p.product_name,
    p.category,
    od.quantity,
    o.total_amount,
    
    SUM(o.total_amount) OVER (
        PARTITION BY c.customer_id
    ) AS customer_total_spent

FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
JOIN order_details od 
    ON o.order_id = od.order_id
JOIN products p 
    ON od.product_id = p.product_id;
    
    
SELECT 
    c.customer_id,
    c.name,
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city;

WITH CustomerSpending AS (
    SELECT 
        c.customer_id,
        c.name,
        c.city,
        SUM(o.total_amount) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name, c.city
)
SELECT *,
       RANK() OVER (ORDER BY total_spent DESC) AS rank_position
FROM CustomerSpending;