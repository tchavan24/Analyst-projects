# 🏠 Rentify SQL Project

## 📌 Project Overview
Rentify is a rental property management database that manages data about landlords, tenants, properties, leases, and payments. The goal is to streamline leasing, tenant tracking, and rent payments across cities.

## 🗃️ Tables
- **LANDLORD** — id, name, phone, email  
- **PROPERTY** — id, address, city, rent, landlord_id  
- **TENANT** — id, name, age, phone, property_id  
- **LEASE** — id, tenant_id, property_id, start_date, end_date, monthly_rent  
- **PAYMENT** — id, lease_id, payment_date, amount_paid, payment_mode

## 🛠️ Stack
MySQL 8+ (works on SQL Workbench/MySQL Workbench)

## 🔍 Highlights
- Proper keys & constraints (PK, FK, UNIQUE, CHECK)
- Joins: INNER/LEFT/RIGHT, CROSS (FULL OUTER via UNION)
- Subqueries (SELECT / WHERE / FROM / scalar)
- Functions: aggregates, string, date
- Window functions: ROW_NUMBER, RANK, DENSE_RANK

## ▶️ How to run
1. Open MySQL Workbench.
2. Run `rentify.sql` (in this folder) top-to-bottom.
3. Use the sample queries at the bottom to explore insights.

## 📑 Files
- `rentify.sql` — full schema, inserts, and queries  
- `README.md` — project description  
