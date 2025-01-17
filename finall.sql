CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
	points INT DEFAULT 0,
    stock INT DEFAULT 0, 
);


CREATE TABLE employees (
    id SERIAL PRIMARY KEY,               
    name VARCHAR(100) NOT NULL,          
    position VARCHAR(50),                
    email VARCHAR(100) UNIQUE NOT NULL, 
    phone VARCHAR(15),                   
    points INT DEFAULT 0,               
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,               
    name VARCHAR(200) NOT NULL,         
    email VARCHAR(100) UNIQUE NOT NULL, 
    phone VARCHAR(15),                 
    address TEXT,                      
    birth_date DATE,                     
    status VARCHAR(20) DEFAULT 'active', 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	purchase_count INT DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0.00 
);
CREATE TABLE communications (
    id SERIAL PRIMARY KEY,                  
    customer_id INT NOT NULL,               
    communication_type VARCHAR(50) NOT NULL,
    details TEXT,                           
    communication_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE CASCADE                  
);
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,                 
    product_id INT NOT NULL,              
    employee_id INT NOT NULL,           
    customer_id INT,                       
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    quantity INT NOT NULL,                 
    total_price DECIMAL(10, 2) NOT NULL,   
    total_points INT,                      
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
);

UPDATE customers
SET status = 'VIP'  
WHERE total_spent > 20000;

INSERT INTO products (name, category, price, points, stock, description)
VALUES
('Laneige Water Sleeping Mask', 'Skin Care', 25.99, 10, 100, 'A popular overnight hydrating mask'),
('Innisfree Green Tea Seed Serum', 'Skin Care', 45.50, 12, 50, 'Hydrating serum with green tea extract'),
('Etude House SoonJung 2x Barrier Intensive Cream', 'Skin Care', 18.99, 8, 200, 'Moisturizing cream for sensitive skin'),
('Dr. Jart+ Cicapair Tiger Grass Color Correcting Treatment', 'Skin Care', 38.00, 15, 120, 'Treatment for red and irritated skin'),
('Sulwhasoo First Care Activating Serum', 'Skin Care', 80.00, 20, 30, 'Premium serum for glowing and youthful skin'),
('Missha Time Revolution The First Treatment Essence', 'Skin Care', 52.99, 14, 70, 'Essence with fermented ingredients to boost skin'),
('Cosrx Advanced Snail 96 Mucin Power Essence', 'Skin Care', 23.00, 9, 150, 'A hydrating essence with snail mucin'),
('Banila Co Clean It Zero Cleansing Balm', 'Makeup Remover', 19.00, 7, 180, 'Cleansing balm for effective makeup removal'),
('The Face Shop Rice Water Bright Cleansing Oil', 'Makeup Remover', 22.50, 6, 160, 'Cleansing oil enriched with rice water'),
('Klairs Supple Preparation Unscented Toner', 'Skin Care', 22.00, 11, 110, 'Alcohol-free toner to balance skin pH');


INSERT INTO employees (name, position, email, phone, points)
VALUES
('John Smith', 'Sales Manager', 'john.smith@example.com', '123-456-7890', 100),
('Alice Brown', 'Sales Representative', 'alice.brown@example.com', '234-567-8901', 150),
('Michael Lee', 'Sales Representative', 'michael.lee@example.com', '345-678-9012', 120),
('Sarah Johnson', 'Sales Representative', 'sarah.johnson@example.com', '456-789-0123', 130),
('David Kim', 'Sales Representative', 'david.kim@example.com', '567-890-1234', 110);


INSERT INTO customers (name, email, phone, address, birth_date, status, purchase_count, total_spent)
VALUES
('Sophia Lee', 'sophia.lee@example.com', '789-012-3456', 'Seoul, South Korea', '1990-03-15', 'active', 10, 25000.00),
('Jin Park', 'jin.park@example.com', '890-123-4567', 'Busan, South Korea', '1985-08-23', 'active', 5, 15000.00),
('Minji Kim', 'minji.kim@example.com', '901-234-5678', 'Incheon, South Korea', '1993-11-30', 'VIP', 20, 22000.00),
('Jiwon Choi', 'jiwon.choi@example.com', '012-345-6789', 'Daegu, South Korea', '1992-06-18', 'active', 12, 30000.00),
('Eunji Cho', 'eunji.cho@example.com', '123-456-7891', 'Seoul, South Korea', '1988-12-04', 'VIP', 15, 22000.00);


INSERT INTO communications (customer_id, communication_type, details)
VALUES
(1, 'Email', 'Promotional email sent regarding new skincare products'),
(2, 'Phone', 'Follow-up call to discuss product recommendations'),
(3, 'Email', 'Discount offer for VIP customers'),
(4, 'Phone', 'Product inquiry call answered by customer support'),
(5, 'SMS', 'Exclusive VIP offer for top customers');


INSERT INTO sales (product_id, employee_id, customer_id, sale_date, quantity, total_price, total_points)
VALUES
(1, 1, 1, '2024-12-10 10:30:00', 1, 25.99, 10),
(2, 2, 2, '2024-12-10 11:00:00', 2, 91.00, 24),
(3, 3, 3, '2024-12-10 11:30:00', 1, 18.99, 8),
(4, 4, 4, '2024-12-10 12:00:00', 3, 114.00, 45),
(5, 5, 5, '2024-12-10 12:30:00', 2, 160.00, 40);

INSERT INTO sales (product_id, employee_id, customer_id, quantity, total_price, total_points)
VALUES (6, 2, 1, 2, 45.99, 20);

SELECT * FROM customers WHERE id = 1;

CREATE OR REPLACE FUNCTION update_customer_totals() RETURNS TRIGGER AS $$
BEGIN
    UPDATE customers
    SET 
        total_spent = total_spent + NEW.total_price,
        purchase_count = purchase_count + 1
    WHERE id = NEW.customer_id;
    RETURN NEW;
END;
$$LANGUAGE plpgsql;

SELECT c.id, c.name, c.total_spent
FROM customers c
ORDER BY c.total_spent DESC
LIMIT 5;

CREATE OR REPLACE PROCEDURE generate_monthly_sales_report()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        DATE_TRUNC('month', sale_date) AS sale_month,
        SUM(total_price) AS total_sales,
        COUNT(*) AS total_transactions
    FROM sales
    GROUP BY sale_month
    ORDER BY sale_month;
END;
$$;

INSERT INTO customers (name, email, phone, address, birth_date, status)
VALUES ('Jane Doe', 'jane.doe@example.com', '999-888-7777', 'New York, USA', '1990-01-01', 'active');


SELECT * FROM customers WHERE status = 'active';

UPDATE customers
SET address = 'Los Angeles, USA'
WHERE id = 1;

DELETE FROM customers WHERE id = 4;

INSERT INTO sales (product_id, employee_id, customer_id, quantity, total_price, total_points)
VALUES (1, 1, 1, 2, 50.00, 20);

SELECT * FROM sales WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31';

UPDATE sales
SET quantity = 3, total_price = 75.00
WHERE id = 1;

DELETE FROM sales WHERE id = 1;

SELECT name, total_spent
FROM customers
ORDER BY total_spent DESC
LIMIT 5;
-- Опр наиболее прибыльных клиентов

SELECT sale_date, total_price, total_points
FROM sales
WHERE DATE_PART('month', sale_date) = DATE_PART('month', CURRENT_DATE)
  AND DATE_PART('year', sale_date) = DATE_PART('year', CURRENT_DATE);
--  Анализ дохода за текущий месяц.

SELECT communication_type, details, communication_date
FROM communications
WHERE customer_id = 3;
-- Посмотреть историю взаимодействий с клиентом.

CREATE OR REPLACE PROCEDURE generate_monthly_report(report_month DATE)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT 
        s.sale_date::DATE AS sale_date,
        c.name AS customer_name,
        s.quantity AS items_sold,
        s.total_price AS total_sale_amount
    FROM sales s
    JOIN customers c ON s.customer_id = c.id
    WHERE DATE_TRUNC('month', s.sale_date) = DATE_TRUNC('month', report_month);
END;
$$;


ALTER TABLE communications
ADD COLUMN employee_id INT,
ADD CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE SET NULL;

select * from communications;
