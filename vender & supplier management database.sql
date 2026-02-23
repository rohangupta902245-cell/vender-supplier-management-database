DROP DATABASE IF EXISTS VendorSupplierDB;
CREATE DATABASE VendorSupplierDB;
USE VendorSupplierDB;

CREATE TABLE Vendor (
    vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE Supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_no VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE Product (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    supplier_id INT NOT NULL,
    FOREIGN KEY (supplier_id)
        REFERENCES Supplier(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE Purchase (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    purchase_date DATE NOT NULL,

    FOREIGN KEY (vendor_id) REFERENCES Vendor(vendor_id),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
) ENGINE=InnoDB;

CREATE TABLE Payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_mode ENUM('Cash','Online','Cheque') NOT NULL,

    FOREIGN KEY (purchase_id)
        REFERENCES Purchase(purchase_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO Vendor (vendor_name, contact_no, email, address)
VALUES
('Rohan Enterprises', '9876543210', 'rohan@gmail.com', 'Mumbai'),
('ABC Traders', '9123456789', 'abc@gmail.com', 'Thane'),
('Star Supplies', '9012345678', 'star@gmail.com', 'Pune'),
('Global Tech', '8899776655', 'global@gmail.com', 'Delhi'),
('Metro Distributors', '9988776655', 'metro@gmail.com', 'Navi Mumbai');

INSERT INTO Supplier (supplier_name, contact_no, email, address)
VALUES
('Tech Source', '9111111111', 'tech@gmail.com', 'Mumbai'),
('IT World', '9222222222', 'itworld@gmail.com', 'Pune'),
('Digital Hub', '9333333333', 'digital@gmail.com', 'Delhi');

INSERT INTO Product (product_name, price, supplier_id)
VALUES
('Laptop', 50000.00, 1),
('Keyboard', 1500.00, 2),
('Mouse', 800.00, 3);

START TRANSACTION;

INSERT INTO Purchase
    (vendor_id, supplier_id, product_id, quantity, total_amount, purchase_date)
VALUES
    (1, 1, 1, 2, 100000.00, CURDATE());

SET @purchase_id = LAST_INSERT_ID();

INSERT INTO Payment
    (purchase_id, amount_paid, payment_date, payment_mode)
VALUES
    (@purchase_id, 100000.00, CURDATE(), 'Online');

COMMIT;

INSERT INTO Payment
    (purchase_id, amount_paid, payment_date, payment_mode)
VALUES
    (1, 50000.00, CURDATE(), 'Cash');

SELECT
    p.purchase_id,
    p.total_amount,
    IFNULL(SUM(py.amount_paid), 0) AS paid_amount,
    (p.total_amount - IFNULL(SUM(py.amount_paid), 0)) AS remaining_balance
FROM Purchase p
LEFT JOIN Payment py
    ON p.purchase_id = py.purchase_id
GROUP BY p.purchase_id, p.total_amount;

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

CREATE OR REPLACE VIEW Purchase_Summary AS
SELECT
    v.vendor_name,
    s.supplier_name,
    SUM(p.total_amount) AS total_purchase_amount
FROM Purchase p
JOIN Vendor v ON p.vendor_id = v.vendor_id
JOIN Supplier s ON p.supplier_id = s.supplier_id
GROUP BY v.vendor_name, s.supplier_name;