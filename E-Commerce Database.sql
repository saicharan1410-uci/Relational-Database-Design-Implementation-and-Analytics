# TASK 1: DATABASE DESIGN & NORMALIZATION
# Schema Creation 
-- Create Database
DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

# Core Entities
-- Customer
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    created_at DATE
);

-- Address
CREATE TABLE Address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- Customer_Address (M:N)
CREATE TABLE Customer_Address (
    customer_id INT,
    address_id INT,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES Address(address_id)
);

-- Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Product
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    stock INT CHECK (stock >= 0)
);

-- Product_Category (M:N)
CREATE TABLE Product_Category (
    product_id INT,
    category_id INT,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- Order
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Shipped','Delivered','Cancelled') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- Order_Item (M:N)
CREATE TABLE Order_Item (
    order_id INT,
    product_id INT,
    quantity INT CHECK (quantity > 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Payment
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_date DATE,
    amount DECIMAL(10,2),
    method VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- Review
CREATE TABLE Review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Supplier
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL
);

-- Product_Supplier (M:N)
CREATE TABLE Product_Supplier (
    product_id INT,
    supplier_id INT,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

# TASK 2: SAMPLE DATA and VIEWS

INSERT INTO Customer (full_name, email, phone) VALUES
('Arjun Mehta','arjun@gmail.com','900111111'),
('Priya Shah','priya@gmail.com','900222222'),
('Rohan Verma','rohan@gmail.com','900333333'),
('Sneha Iyer','sneha@gmail.com','900444444'),
('Karan Singh','karan@gmail.com','900555555'),
('Anita Rao','anita@gmail.com','900666666');


INSERT INTO Address (city, country) VALUES
('Mumbai','India'),
('Delhi','India'),
('Bengaluru','India'),
('Chennai','India'),
('Pune','India'),
('Hyderabad','India');

INSERT INTO Customer_Address VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,5),
(6,6);

INSERT INTO Category (category_name) VALUES
('Electronics'),
('Fashion'),
('Home Appliances'),
('Books'),
('Sports');

INSERT INTO Product (product_name, price, stock) VALUES
('Laptop',70000,10),
('Smartphone',40000,15),
('Bluetooth Speaker',5000,20),
('T-Shirt',1200,50),
('Microwave Oven',15000,8),
('Cricket Bat',3500,25),
('Programming Book',900,40);

INSERT INTO Product_Category VALUES
(1,1),
(2,1),
(3,1),
(4,2),
(5,3),
(6,5),
(7,4);

INSERT INTO Orders (customer_id, status, order_date) VALUES
(1,'Delivered','2025-01-05'),
(2,'Delivered','2025-01-08'),
(3,'Pending','2025-01-12'),
(4,'Shipped','2025-01-15'),
(5,'Cancelled','2025-01-18'),
(6,'Delivered','2025-01-20');

INSERT INTO Order_Item VALUES
(1,1,1),
(1,4,2),
(2,2,1),
(3,3,1),
(4,5,1),
(4,7,2),
(6,6,1),
(6,4,3);

INSERT INTO Payment (order_id, payment_date, amount, method) VALUES
(1,'2025-01-06',72400,'Card'),
(2,'2025-01-09',40000,'UPI'),
(4,'2025-01-16',15000,'Net Banking'),
(6,'2025-01-21',14100,'Card'),
(3,'2025-01-13',5000,'UPI');

INSERT INTO Review (customer_id, product_id, rating, comment) VALUES
(1,1,5,'Excellent performance'),
(2,2,4,'Very good phone'),
(3,3,4,'Good sound quality'),
(4,5,5,'Works perfectly'),
(6,6,4,'Great for beginners');

INSERT INTO Supplier (supplier_name) VALUES
('Tech Distributors'),
('Fashion Hub'),
('Home Essentials Ltd'),
('Book World'),
('Sports Gear Co');

INSERT INTO Product_Supplier VALUES
(1,1),
(2,1),
(3,1),
(4,2),
(5,3),
(7,4),
(6,5);

# Views
-- View 1: Total Sales per Customer
CREATE VIEW Customer_Sales AS
SELECT c.full_name, SUM(p.amount) AS total_spent
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.full_name;

-- View 2: Product Sales Trend
CREATE VIEW Product_Sales_Trend AS
SELECT pr.product_name, SUM(oi.quantity) AS total_sold
FROM Product pr
JOIN Order_Item oi ON pr.product_id = oi.product_id
GROUP BY pr.product_name;

# TASK 3: ADVANCED SQL ANALYTICS
-- Query 1 – Top Customers
SELECT c.full_name, SUM(p.amount) AS revenue
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.full_name
ORDER BY revenue DESC;

-- Query 2 – Products with Above-Average Sales (Subquery)
SELECT product_name
FROM Product
WHERE product_id IN (
    SELECT product_id
    FROM Order_Item
    GROUP BY product_id
    HAVING SUM(quantity) >
        (SELECT AVG(quantity) FROM Order_Item)
);

-- Query 3 – Customer Segmentation (CASE)
SELECT c.full_name,
CASE
    WHEN SUM(p.amount) > 50000 THEN 'Premium'
    WHEN SUM(p.amount) BETWEEN 20000 AND 50000 THEN 'Regular'
    ELSE 'Low Value'
END AS customer_category
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.full_name;

-- Query 4 – Revenue Ranking (Window Function)
SELECT c.full_name,
SUM(p.amount) AS total_spent,
RANK() OVER (ORDER BY SUM(p.amount) DESC) AS spending_rank
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payment p ON o.order_id = p.order_id
GROUP BY c.full_name;

-- Query 5 – Stored Procedure (Monthly Sales)
DELIMITER //
CREATE PROCEDURE MonthlySales(IN m INT)
BEGIN
    SELECT *
    FROM Orders
    WHERE MONTH(order_date) = m;
END //
DELIMITER ;

# TASK 5: QUERY PERFORMANCE  and OPTIMIZATION
-- Inefficient Query
SELECT *
FROM Orders
WHERE customer_id IN (
    SELECT customer_id FROM Customer WHERE email LIKE '%gmail%'
);

-- Optimization 1: Index
CREATE INDEX idx_customer_email ON Customer(email);

-- Optimization 2: JOIN Rewrite
SELECT o.*
FROM Orders o
JOIN Customer c ON o.customer_id = c.customer_id
WHERE c.email LIKE '%gmail%';




















 















