-- Rentify SQL Project (MySQL 8+)
-- Creates schema, loads sample data, and runs demo queries

-- 0) Create & use database (optional if you already have one)
CREATE DATABASE IF NOT EXISTS rentify_db;
USE rentify_db;

-- 1) Landlord
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Lease;
DROP TABLE IF EXISTS Tenant;
DROP TABLE IF EXISTS Property;
DROP TABLE IF EXISTS Landlord;

CREATE TABLE Landlord (
  landlord_id INT PRIMARY KEY,
  name        VARCHAR(50)  NOT NULL,
  phone       VARCHAR(20)  UNIQUE,
  email       VARCHAR(100) UNIQUE
);

INSERT INTO Landlord (landlord_id, name, phone, email) VALUES
(1, 'Rajesh Mehra', '9876543210', 'r.mehra@email.com'),
(2, 'Anita Kapoor', '9123456789', 'a.kapoor@email.com'),
(3, 'Suresh Patil', '9012345678', 's.patil@email.com');

-- 2) Property
CREATE TABLE Property (
  property_id INT PRIMARY KEY,
  address     VARCHAR(255) NOT NULL,
  city        VARCHAR(50)  NOT NULL,
  rent        INT CHECK (rent > 0),
  landlord_id INT,
  FOREIGN KEY (landlord_id) REFERENCES Landlord(landlord_id)
);

INSERT INTO Property (property_id, address, city, rent, landlord_id) VALUES
(101, 'A-101, Green Street', 'Mumbai',      25000, 1),
(102, 'B-202, Blue Hills',   'Pune',        18000, 2),
(103, 'C-303, Lake View',    'Thane',       30000, 3),
(104, 'D-33, Palm Beach Rd', 'Navi Mumbai', 22000, 2);

-- 3) Tenant
CREATE TABLE Tenant (
  tenant_id   INT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  age         INT CHECK (age > 0),
  phone       VARCHAR(50) UNIQUE NOT NULL,
  property_id INT,
  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

INSERT INTO Tenant (tenant_id, name, age, phone, property_id) VALUES
(1, 'Ayaan Khan', 28, '9876512345', 101),
(2, 'Neha Sharma',32, '9123456781', 102),
(3, 'Raj Verma',  26, '9012345698', 103);

-- 4) Lease
CREATE TABLE Lease (
  lease_id     INT PRIMARY KEY,
  tenant_id    INT NOT NULL,
  property_id  INT NOT NULL,
  start_date   DATE NOT NULL,
  end_date     DATE,
  monthly_rent INT CHECK (monthly_rent > 0),
  FOREIGN KEY (tenant_id)   REFERENCES Tenant(tenant_id),
  FOREIGN KEY (property_id) REFERENCES Property(property_id)
);

INSERT INTO Lease (lease_id, tenant_id, property_id, start_date, end_date, monthly_rent) VALUES
(1, 1, 101, '2023-01-01', '2023-12-31', 25000),
(2, 2, 102, '2023-03-01', '2024-02-28', 18000),
(3, 3, 103, '2023-07-01', '2024-06-30', 30000);

-- 5) Payment
CREATE TABLE Payment (
  payment_id   INT PRIMARY KEY,
  lease_id     INT NOT NULL,
  payment_date DATE NOT NULL,
  amount_paid  INT CHECK (amount_paid > 0),
  payment_mode ENUM('Cash','Online','Cheque') DEFAULT 'Cash',
  FOREIGN KEY (lease_id) REFERENCES Lease(lease_id)
);

INSERT INTO Payment (payment_id, lease_id, payment_date, amount_paid, payment_mode) VALUES
(1, 1, '2023-02-01', 25000, 'Online'),
(2, 1, '2023-03-01', 25000, 'Cash'),
(3, 2, '2024-02-10', 18000, 'Cheque'),
(4, 3, '2023-07-01', 30000, 'Online');

-- =========================
-- ANALYSIS QUERIES
-- =========================

-- A) Lease summary with tenant, property & landlord
SELECT t.tenant_id,
       t.name         AS tenant_name,
       p.address      AS property_address,
       p.city,
       l.start_date,
       l.end_date,
       l.monthly_rent,
       ld.name        AS landlord_name,
       ld.phone       AS landlord_contact
FROM Tenant t
JOIN Lease l     ON t.tenant_id   = l.tenant_id
JOIN Property p  ON l.property_id = p.property_id
JOIN Landlord ld ON p.landlord_id = ld.landlord_id;

-- B) Payment history per tenant (ordered)
SELECT t.tenant_id,
       t.name AS tenant_name,
       pm.payment_id,
       pm.payment_date,
       pm.amount_paid,
       pr.property_id,
       pr.address AS property_address
FROM Payment pm
JOIN Lease l   ON pm.lease_id     = l.lease_id
JOIN Tenant t  ON l.tenant_id     = t.tenant_id
JOIN Property pr ON l.property_id = pr.property_id
ORDER BY t.tenant_id, pm.payment_date;

-- C) LEFT JOIN: all tenants regardless of lease
SELECT t.tenant_id, t.name AS tenant_name, l.lease_id, l.start_date, l.end_date
FROM Tenant t
LEFT JOIN Lease l ON t.tenant_id = l.tenant_id;

-- D) RIGHT JOIN: all leases even if tenant info missing
SELECT l.lease_id, t.tenant_id, t.name AS tenant_name
FROM Tenant t
RIGHT JOIN Lease l ON t.tenant_id = l.tenant_id;

-- E) FULL OUTER JOIN (MySQL workaround via UNION)
SELECT t.name AS tenant_name, l.lease_id, l.start_date
FROM Tenant t
LEFT JOIN Lease l ON t.tenant_id = l.tenant_id
UNION
SELECT t.name AS tenant_name, l.lease_id, l.start_date
FROM Tenant t
RIGHT JOIN Lease l ON t.tenant_id = l.tenant_id
WHERE t.tenant_id IS NULL;

-- F) CROSS JOIN: every tenant-property combination
SELECT t.name AS tenant_name, p.address AS property_address
FROM Tenant t
CROSS JOIN Property p;

-- G) Subqueries
-- G1: Show property vs average rent
SELECT address, city, rent,
       (SELECT AVG(rent) FROM Property) AS average_rent
FROM Property;

-- G2: Properties with rent above average
SELECT property_id, address, rent
FROM Property
WHERE rent > (SELECT AVG(rent) FROM Property);

-- G3: Subquery in FROM
SELECT t.name, li.start_date, li.end_date
FROM Tenant t
JOIN (
  SELECT tenant_id, start_date, end_date
  FROM Lease
) AS li ON t.tenant_id = li.tenant_id;

-- G4: Scalar subquery: monthly rent per tenant
SELECT name,
       (SELECT monthly_rent FROM Lease WHERE Lease.tenant_id = Tenant.tenant_id) AS rent
FROM Tenant;

-- H) Functions
-- H1: Aggregate
SELECT COUNT(*) AS total_properties,
       SUM(rent) AS total_rent,
       AVG(rent) AS average_rent
FROM Property;

-- H2: String (use CHAR_LENGTH for length in chars)
SELECT name,
       UPPER(name)            AS name_upper,
       CHAR_LENGTH(name)      AS name_length
FROM Tenant;

-- H3: Date (DATEDIFF returns end - start in days)
SELECT lease_id, start_date, end_date,
       DATEDIFF(end_date, start_date) AS lease_duration_days
FROM Lease;

-- I) Window functions (MySQL 8+)
SELECT tenant_id, name, age,
       ROW_NUMBER() OVER (ORDER BY age DESC) AS row_num,
       RANK()       OVER (ORDER BY
