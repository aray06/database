-- Laboratory Work 5: Database Constraints
-- Student: Aray Yessengeldiyeva
-- Student ID: 25B032092
-- PostgreSQL 18

-- Task 1.1: Basic CHECK
CREATE TABLE employees (
 employee_id INTEGER, first_name TEXT, last_name TEXT,
 age INTEGER CHECK (age BETWEEN 18 AND 65),
 salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2: Named CHECK
CREATE TABLE products_catalog (
 product_id INTEGER, product_name TEXT, regular_price NUMERIC, discount_price NUMERIC,
 CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

-- Task 1.3: Multiple-column CHECK
CREATE TABLE bookings (
 booking_id INTEGER, check_in_date DATE, check_out_date DATE,
 num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
 CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Valid and invalid CHECK tests
INSERT INTO employees VALUES (1,'John','Smith',25,50000),(2,'Anna','Brown',30,60000);
INSERT INTO products_catalog VALUES (1,'Laptop',1000,800),(2,'Phone',700,600);
INSERT INTO bookings VALUES (1,'2026-10-15','2026-10-20',2),(2,'2026-11-01','2026-11-05',4);
-- Expected CHECK violation: age is below 18
-- INSERT INTO employees VALUES (3,'Alex','Lee',16,40000);
-- Expected CHECK violation: salary is not positive
-- INSERT INTO employees VALUES (4,'Tom','White',28,-1000);
-- Expected valid_discount CHECK violation: regular_price is negative
-- INSERT INTO products_catalog VALUES (3,'Tablet',-500,200);
-- Expected valid_discount CHECK violation: discount_price is negative
-- INSERT INTO products_catalog VALUES (4,'Mouse',100,-10);
-- Expected valid_discount CHECK violation: discount exceeds regular price
-- INSERT INTO products_catalog VALUES (5,'Keyboard',100,120);
-- Expected CHECK violation: too many guests
-- INSERT INTO bookings VALUES (3,'2026-10-15','2026-10-20',15);
-- Expected CHECK violation: check-out precedes check-in
-- INSERT INTO bookings VALUES (4,'2026-10-20','2026-10-15',2);
SELECT * FROM employees;
SELECT * FROM products_catalog;
SELECT * FROM bookings;

-- Task 2.1: NOT NULL
CREATE TABLE customers (
 customer_id INTEGER NOT NULL, email TEXT NOT NULL,
 phone TEXT, registration_date DATE NOT NULL
);

-- Task 2.2: Combining NOT NULL and CHECK
CREATE TABLE inventory (
 item_id INTEGER NOT NULL, item_name TEXT NOT NULL,
 quantity INTEGER NOT NULL CHECK (quantity >= 0),
 unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
 last_updated TIMESTAMP NOT NULL
);

-- Task 2.3: Test NOT NULL and nullable fields
INSERT INTO customers VALUES
 (1,'john@gmail.com','87011234567','2026-10-01'),
 (2,'anna@gmail.com',NULL,'2026-10-02');
-- Result: phone accepts NULL because it has no NOT NULL constraint.
INSERT INTO inventory VALUES
 (1,'Laptop',10,350000,CURRENT_TIMESTAMP),
 (2,'Mouse',25,5000,CURRENT_TIMESTAMP);
-- Expected NOT NULL violation: customer_id
-- INSERT INTO customers VALUES (NULL,'test@gmail.com','87010000000','2026-10-03');
-- Expected NOT NULL violation: email
-- INSERT INTO customers VALUES (3,NULL,'87010000000','2026-10-03');
-- Expected NOT NULL violation: registration_date
-- INSERT INTO customers VALUES (3,'test@gmail.com',NULL,NULL);
-- Expected NOT NULL violation: item_id
-- INSERT INTO inventory VALUES (NULL,'Keyboard',5,10000,CURRENT_TIMESTAMP);
-- Expected NOT NULL violation: item_name
-- INSERT INTO inventory VALUES (3,NULL,5,1000,CURRENT_TIMESTAMP);
-- Expected NOT NULL violation: quantity
-- INSERT INTO inventory VALUES (3,'Keyboard',NULL,10000,CURRENT_TIMESTAMP);
-- Expected NOT NULL violation: unit_price
-- INSERT INTO inventory VALUES (3,'Keyboard',5,NULL,CURRENT_TIMESTAMP);
-- Expected NOT NULL violation: last_updated
-- INSERT INTO inventory VALUES (3,'Keyboard',5,10000,NULL);
-- Expected CHECK violation: quantity is negative
-- INSERT INTO inventory VALUES (3,'Keyboard',-5,10000,CURRENT_TIMESTAMP);
-- Expected CHECK violation: unit_price is negative
-- INSERT INTO inventory VALUES (3,'Keyboard',5,-1000,CURRENT_TIMESTAMP);
SELECT * FROM customers;
SELECT * FROM inventory;

-- Task 3.1: Single-column UNIQUE
CREATE TABLE users (
 user_id INTEGER, username TEXT UNIQUE, email TEXT UNIQUE, created_at TIMESTAMP
);

-- Task 3.2: Multi-column UNIQUE
CREATE TABLE course_enrollments (
 enrollment_id INTEGER, student_id INTEGER, course_code TEXT, semester TEXT,
 CONSTRAINT unique_enrollment UNIQUE (student_id,course_code,semester)
);
INSERT INTO course_enrollments VALUES
 (1,1,'CS101','Fall 2026'),(2,1,'CS101','Spring 2027'),(3,2,'CS101','Fall 2026');
-- Expected UNIQUE violation: repeated student/course/semester combination
-- INSERT INTO course_enrollments VALUES (4,1,'CS101','Fall 2026');

-- Task 3.3: Replace automatic names with named UNIQUE constraints
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE(username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);
INSERT INTO users VALUES
 (1,'john123','john@gmail.com',CURRENT_TIMESTAMP),
 (2,'anna123','anna@gmail.com',CURRENT_TIMESTAMP);
-- Expected unique_username violation: duplicate username
-- INSERT INTO users VALUES (3,'john123','new@gmail.com',CURRENT_TIMESTAMP);
-- Expected unique_email violation: duplicate email
-- INSERT INTO users VALUES (4,'michael123','anna@gmail.com',CURRENT_TIMESTAMP);
SELECT * FROM users;
SELECT * FROM course_enrollments;

-- Task 4.1: Single-column PRIMARY KEY
CREATE TABLE departments (
 dept_id INTEGER PRIMARY KEY, dept_name TEXT NOT NULL, location TEXT
);
INSERT INTO departments VALUES
 (1,'IT','Almaty'),(2,'HR','Astana'),(3,'Sales','Shymkent');
-- Expected PRIMARY KEY violation: duplicate dept_id
-- INSERT INTO departments VALUES (1,'Finance','Almaty');
-- Expected NOT NULL violation: NULL primary key
-- INSERT INTO departments VALUES (NULL,'Marketing','Astana');
SELECT * FROM departments;

-- Task 4.2: Composite PRIMARY KEY
CREATE TABLE student_courses (
 student_id INTEGER, course_id INTEGER, enrollment_date DATE, grade TEXT,
 PRIMARY KEY(student_id,course_id)
);
INSERT INTO student_courses VALUES
 (1,101,'2026-09-01','A'),(1,102,'2026-09-02','B'),
 (2,101,'2026-09-03','A'),(3,103,'2026-09-04','C');
-- Expected PRIMARY KEY violation: duplicate pair (1,101)
-- INSERT INTO student_courses VALUES (1,101,'2026-09-05','B');
-- Expected NOT NULL violation: student_id is part of primary key
-- INSERT INTO student_courses VALUES (NULL,104,'2026-09-06','A');
SELECT * FROM student_courses;

-- Task 4.3: Comparison Exercise
-- 1. PRIMARY KEY uniquely identifies each row and never permits NULL.
--    UNIQUE also disallows duplicate non-NULL values, but PostgreSQL normally
--    permits multiple NULLs under a UNIQUE constraint.
-- 2. Use a single-column PRIMARY KEY when one field identifies a row.
--    Use a composite PRIMARY KEY when a combination of fields identifies it.
-- 3. Each table has one designated PRIMARY KEY (which may include multiple
--    columns), but it may have multiple other candidate keys enforced by UNIQUE.

-- Task 5.1: Basic FOREIGN KEY
CREATE TABLE employees_dept (
 emp_id INTEGER PRIMARY KEY, emp_name TEXT NOT NULL,
 dept_id INTEGER REFERENCES departments(dept_id), hire_date DATE
);
INSERT INTO employees_dept VALUES
 (1,'John Smith',1,'2024-01-15'),
 (2,'Anna Brown',2,'2024-03-20'),
 (3,'Michael Lee',3,'2025-06-10');
-- Expected FOREIGN KEY violation: department 99 does not exist
-- INSERT INTO employees_dept VALUES (4,'Alex White',99,'2025-09-01');
SELECT * FROM employees_dept;

-- Task 5.2: Library system with multiple FOREIGN KEYs
CREATE TABLE authors (
 author_id INTEGER PRIMARY KEY, author_name TEXT NOT NULL, country TEXT
);
CREATE TABLE publishers (
 publisher_id INTEGER PRIMARY KEY, publisher_name TEXT NOT NULL, city TEXT
);
CREATE TABLE books (
 book_id INTEGER PRIMARY KEY, title TEXT NOT NULL,
 author_id INTEGER REFERENCES authors(author_id),
 publisher_id INTEGER REFERENCES publishers(publisher_id),
 publication_year INTEGER, isbn TEXT UNIQUE
);
INSERT INTO authors VALUES
 (1,'J.K. Rowling','United Kingdom'),
 (2,'George Orwell','United Kingdom'),
 (3,'Mark Twain','United States');
INSERT INTO publishers VALUES
 (1,'Bloomsbury','London'),
 (2,'Penguin Books','London'),
 (3,'HarperCollins','New York');
INSERT INTO books VALUES
 (1,'Harry Potter',1,1,1997,'9780747532699'),
 (2,'1984',2,2,1949,'9780451524935'),
 (3,'Tom Sawyer',3,3,1876,'9780486400778');
-- Expected FOREIGN KEY violation: missing author
-- INSERT INTO books VALUES (4,'Unknown Book',999,1,2026,'1234567890123');
-- Expected FOREIGN KEY violation: missing publisher
-- INSERT INTO books VALUES (4,'Unknown Book',1,999,2026,'1234567890123');
SELECT * FROM authors;
SELECT * FROM publishers;
SELECT * FROM books;

-- Task 5.3: ON DELETE RESTRICT and CASCADE
CREATE TABLE categories (
 category_id INTEGER PRIMARY KEY, category_name TEXT NOT NULL
);
CREATE TABLE products_fk (
 product_id INTEGER PRIMARY KEY, product_name TEXT NOT NULL,
 category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);
CREATE TABLE orders (
 order_id INTEGER PRIMARY KEY, order_date DATE NOT NULL
);
CREATE TABLE order_items (
 item_id INTEGER PRIMARY KEY,
 order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
 product_id INTEGER REFERENCES products_fk(product_id),
 quantity INTEGER CHECK(quantity > 0)
);
INSERT INTO categories VALUES (1,'Electronics'),(2,'Clothing');
INSERT INTO products_fk VALUES (1,'Laptop',1),(2,'Phone',1),(3,'T-Shirt',2);
INSERT INTO orders VALUES (1,'2026-10-10'),(2,'2026-10-11');
INSERT INTO order_items VALUES (1,1,1,2),(2,1,2,1),(3,2,3,3);
-- Expected RESTRICT violation: category 1 is referenced by products_fk
-- DELETE FROM categories WHERE category_id=1;
-- CASCADE demonstration: removing order 1 deletes its two order_items.
DELETE FROM orders WHERE order_id=1;
-- Expected result: orders contains only order 2; order_items contains only item 3.
SELECT * FROM categories;
SELECT * FROM orders;
SELECT * FROM order_items;

-- Task 6.1: E-commerce database in a separate schema to avoid name collisions
CREATE SCHEMA ecommerce;
CREATE TABLE ecommerce.customers (
 customer_id INTEGER PRIMARY KEY, name TEXT NOT NULL,
 email TEXT NOT NULL UNIQUE, phone TEXT, registration_date DATE NOT NULL
);
CREATE TABLE ecommerce.products (
 product_id INTEGER PRIMARY KEY, name TEXT NOT NULL, description TEXT,
 price NUMERIC(10,2) NOT NULL CHECK(price >= 0),
 stock_quantity INTEGER NOT NULL CHECK(stock_quantity >= 0)
);
CREATE TABLE ecommerce.orders (
 order_id INTEGER PRIMARY KEY,
 customer_id INTEGER NOT NULL REFERENCES ecommerce.customers(customer_id) ON DELETE RESTRICT,
 order_date DATE NOT NULL,
 total_amount NUMERIC(10,2) NOT NULL CHECK(total_amount >= 0),
 status TEXT NOT NULL CHECK(status IN ('pending','processing','shipped','delivered','cancelled'))
);
CREATE TABLE ecommerce.order_details (
 order_detail_id INTEGER PRIMARY KEY,
 order_id INTEGER NOT NULL REFERENCES ecommerce.orders(order_id) ON DELETE CASCADE,
 product_id INTEGER NOT NULL REFERENCES ecommerce.products(product_id) ON DELETE RESTRICT,
 quantity INTEGER NOT NULL CHECK(quantity > 0),
 unit_price NUMERIC(10,2) NOT NULL CHECK(unit_price >= 0)
);
INSERT INTO ecommerce.customers VALUES
 (1,'John Smith','john@gmail.com','87011111111','2026-01-10'),
 (2,'Anna Brown','anna@gmail.com','87012222222','2026-02-15'),
 (3,'Michael Lee','michael@gmail.com','87013333333','2026-03-20'),
 (4,'Emily Davis','emily@gmail.com',NULL,'2026-04-05'),
 (5,'Robert Wilson','robert@gmail.com','87015555555','2026-05-12');
INSERT INTO ecommerce.products VALUES
 (1,'Laptop','Gaming laptop',350000,10),
 (2,'Mouse','Wireless mouse',5000,50),
 (3,'Keyboard','Mechanical keyboard',15000,30),
 (4,'Monitor','24 inch monitor',75000,20),
 (5,'Headphones','Bluetooth headphones',25000,40);
INSERT INTO ecommerce.orders VALUES
 (1,1,'2026-10-01',350000,'pending'),
 (2,2,'2026-10-02',10000,'processing'),
 (3,3,'2026-10-03',15000,'shipped'),
 (4,4,'2026-10-04',75000,'delivered'),
 (5,5,'2026-10-05',25000,'cancelled');
INSERT INTO ecommerce.order_details VALUES
 (1,1,1,1,350000),
 (2,2,2,2,5000),
 (3,3,3,1,15000),
 (4,4,4,1,75000),
 (5,5,5,1,25000);
-- Expected UNIQUE violation: customer email already exists
-- INSERT INTO ecommerce.customers VALUES (6,'Test','john@gmail.com',NULL,CURRENT_DATE);
-- Expected NOT NULL violation: customer name is NULL
-- INSERT INTO ecommerce.customers VALUES (6,NULL,'test@gmail.com',NULL,CURRENT_DATE);
-- Expected PRIMARY KEY violation: duplicate product ID
-- INSERT INTO ecommerce.products VALUES (1,'Tablet','New tablet',1000,5);
-- Expected CHECK violation: negative price
-- INSERT INTO ecommerce.products VALUES (6,'Tablet','New tablet',-1000,10);
-- Expected CHECK violation: negative stock
-- INSERT INTO ecommerce.products VALUES (6,'Tablet','New tablet',1000,-5);
-- Expected CHECK violation: invalid order status
-- INSERT INTO ecommerce.orders VALUES (6,1,CURRENT_DATE,1000,'unknown');
-- Expected FOREIGN KEY violation: customer 999 does not exist
-- INSERT INTO ecommerce.orders VALUES (6,999,CURRENT_DATE,1000,'pending');
-- Expected CHECK violation: quantity must be positive
-- INSERT INTO ecommerce.order_details VALUES (6,1,1,0,350000);
-- Expected CHECK violation: negative unit_price
-- INSERT INTO ecommerce.order_details VALUES (6,1,1,1,-1);
-- Expected FOREIGN KEY violation: product 999 does not exist
-- INSERT INTO ecommerce.order_details VALUES (6,1,999,1,100);
-- Expected ON DELETE RESTRICT: customer 1 has an order
-- DELETE FROM ecommerce.customers WHERE customer_id=1;
-- Expected ON DELETE RESTRICT: product 1 has an order detail
-- DELETE FROM ecommerce.products WHERE product_id=1;
-- Expected ON DELETE CASCADE: deleting order 1 also deletes detail 1
-- DELETE FROM ecommerce.orders WHERE order_id=1;
-- Successful tests: five rows in each table, with consistent order totals.
SELECT * FROM ecommerce.customers;
SELECT * FROM ecommerce.products;
SELECT * FROM ecommerce.orders;
SELECT * FROM ecommerce.order_details;
