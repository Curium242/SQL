-- Create tables
CREATE TABLE users (
  user_id INT PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(50),
  age INT,
  address VARCHAR(100)
);

CREATE TABLE payments (
  payment_id INT PRIMARY KEY,
  user_id INT,
  amount DECIMAL(10,2),
  payment_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
  category_id INT PRIMARY KEY,
  name VARCHAR(50)
);
CREATE TABLE products (
  product_id INT PRIMARY KEY,
  name VARCHAR(50),
  price DECIMAL(10,2),
  category_id INT,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE cart_items (
  item_id INT PRIMARY KEY,
  user_id INT,
  product_id INT,
  quantity INT,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert data into users table
INSERT INTO users (user_id, name, email, age, address) VALUES (1, 'Rajesh Patel', 'rajesh.patel@gmail.com', 30, '123 Dance St');
INSERT INTO users (user_id, name, email, age, address) VALUES (2, 'Neha Gupta', 'neha.gupta@gmail.com', 25, '420 Green St');
INSERT INTO users (user_id, name, email, age, address) VALUES (3, 'Amit Sharma', 'amit.sharma@gmail.com', 35, '690 Wood St');
INSERT INTO users (user_id, name, email, age, address) VALUES (4, 'Priya Singh', 'priya.singh@gmail.com', 28, '911 Nehru St');
INSERT INTO users (user_id, name, email, age, address) VALUES (5, 'Anil Verma', 'anil.verma@gmail.com', 32, '764 Cedar St');

-- Insert data into payments table
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (1, 1, 100.00, TO_DATE('2023-07-15', 'YYYY-MM-DD'));
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (2, 2, 50.00, TO_DATE('2023-07-14', 'YYYY-MM-DD'));
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (3, 3, 75.00, TO_DATE('2023-07-13', 'YYYY-MM-DD'));
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (4, 1, 150.00, TO_DATE('2023-07-12', 'YYYY-MM-DD'));
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (5, 3, 200.00, TO_DATE('2023-07-16', 'YYYY-MM-DD'));
INSERT INTO payments (payment_id, user_id, amount, payment_date) VALUES (6, 5, 75.00, TO_DATE('2023-07-17', 'YYYY-MM-DD'));

-- Insert data into categories table
INSERT INTO categories (category_id, name) VALUES (1, 'Electronics');
INSERT INTO categories (category_id, name) VALUES (2, 'Grocery');
INSERT INTO categories (category_id, name) VALUES (3, 'Clothing');

-- Insert data into products table
INSERT INTO products (product_id, name, price, category_id) VALUES (1, 'iPhone', 299999.99, 1);
INSERT INTO products (product_id, name, price, category_id) VALUES (2, 'Chocolate', 42.53, 2);
INSERT INTO products (product_id, name, price, category_id) VALUES (3, 'shirt', 1250.57, 3);

-- Insert data into cart_items table
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (1, 1, 2, 2);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (2, 2, 2, 1);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (3, 3, 3, 3);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (4, 1, 2, 3);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (5, 3, 3, 1);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (6, 4, 1, 2);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (7, 3, 2, 1);
INSERT INTO cart_items (item_id, user_id, product_id, quantity) VALUES (8, 5, 3, 2);
-- Display all users
SELECT 'User ID: ' || user_id || ', Name: ' || name || ', Email: ' || email || ', Age: ' || age || ', Address: ' || address AS user_info FROM users;

-- Update user's email using PL/SQL block
BEGIN
  UPDATE users SET email = 'rajesh@gmail.com' WHERE user_id = 1;
  COMMIT;
END;
/
-- Delete a user using PL/SQL block
DECLARE
  user_id_to_delete INT := 3;
BEGIN
  -- Delete related child records
  DELETE FROM cart_items WHERE user_id = user_id_to_delete;
  DELETE FROM payments WHERE user_id = user_id_to_delete;
  -- Delete the user
  DELETE FROM users WHERE user_id = user_id_to_delete;
  DBMS_OUTPUT.PUT_LINE('User with ID ' || user_id_to_delete || ' and related records have been deleted.');
END;
/
-- Calculate total payment amount for each user
SELECT 'User ID: ' || u.user_id || ', Name: ' || u.name || ', Total Amount: ' || COALESCE(SUM(p.amount), 0) AS payment_info
FROM users u
LEFT JOIN payments p ON u.user_id = p.user_id
GROUP BY u.user_id, u.name;

-- Display the average price of all products
SELECT 'Average Price: ' || AVG(price) AS avg_price FROM products;

-- Count the number of products in each category
SELECT 'Category: ' || c.name || ', Product Count: ' || COUNT(*) AS category_info
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.name;

-- To display what each user has in their cart
SELECT u.name AS user_name, p.name AS product_name, ci.quantity
FROM users u
JOIN cart_items ci ON u.user_id = ci.user_id
JOIN products p ON ci.product_id = p.product_id;

-- Find the most expensive product
SELECT 'Most Expensive Product - ID: ' || product_id || ', Name: ' || name || ', Price: ' || price AS most_expensive_product
FROM products
ORDER BY price DESC
FETCH FIRST ROW ONLY;

-- Calculate the total quantity of a specific product in the cart
SELECT SUM(quantity) AS total_quantity
FROM cart_items ci
JOIN products p ON ci.product_id = p.product_id
WHERE p.name = 'iPhone';

-- Find the user with the highest total payment amount using PL/SQL block
DECLARE
  highest_payment_user_id INT;
  user_info VARCHAR2(200);
BEGIN
  SELECT user_id INTO highest_payment_user_id
  FROM (
    SELECT user_id, SUM(amount) AS total_amount
    FROM payments
    GROUP BY user_id
    ORDER BY total_amount DESC
  )
  WHERE ROWNUM = 1;

  SELECT 'User with Highest Total Payment Amount - ID: ' || u.user_id || ', Name: ' || u.name
  INTO user_info
  FROM users u
  WHERE u.user_id = highest_payment_user_id;

  DBMS_OUTPUT.PUT_LINE(user_info);
END;
/
DECLARE
  average_order_value NUMBER;
-- Calculate the average order value using PL/SQL
BEGIN
  SELECT AVG(amount)
  INTO average_order_value
  FROM payments;

  DBMS_OUTPUT.PUT_LINE('Average Order Value: ' || average_order_value);
END;
/
