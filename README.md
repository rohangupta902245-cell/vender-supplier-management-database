# VendorSupplierDB

A relational MySQL database for managing vendors, suppliers, products, purchases, and payments.

---

## Database Schema

### Tables

**Vendor** — Stores vendor information (name, contact, email, address).

**Supplier** — Stores supplier information (name, contact, email, address).

**Product** — Stores products with pricing, each linked to a supplier via `supplier_id`.

**Purchase** — Records purchases made by a vendor from a supplier for a specific product, including quantity, total amount, and date.

**Payment** — Records payments against a purchase. Supports partial payments. Cascades on purchase deletion. Payment modes: `Cash`, `Online`, or `Cheque`.

### Relationships

```
Supplier  ──< Product
Vendor    ──< Purchase >── Supplier
                │
                └──< Payment
```

---

## Getting Started

### Prerequisites

- MySQL 5.7+ or MariaDB

### Setup

Run the SQL file in your MySQL client:

```bash
mysql -u your_username -p < vendor_supplier_db.sql
```

Or paste the script directly into MySQL Workbench / any SQL client.

---

## Sample Data

| Table    | Records |
|----------|---------|
| Vendor   | 5       |
| Supplier | 3       |
| Product  | 3       |

**Sample products:** Laptop (₹50,000), Keyboard (₹1,500), Mouse (₹800)

---

## Key Features

### Transactions
Purchases and their initial payments are inserted atomically using `START TRANSACTION` / `COMMIT`, ensuring data integrity.

### Partial Payments
The Payment table supports multiple payments per purchase, enabling partial payment tracking.

### Balance Check Query
A built-in query calculates the outstanding balance per purchase:

```sql
SELECT
    p.purchase_id,
    p.total_amount,
    IFNULL(SUM(py.amount_paid), 0) AS paid_amount,
    (p.total_amount - IFNULL(SUM(py.amount_paid), 0)) AS remaining_balance
FROM Purchase p
LEFT JOIN Payment py ON p.purchase_id = py.purchase_id
GROUP BY p.purchase_id, p.total_amount;
```

### Purchase Summary View
A view (`Purchase_Summary`) aggregates total purchase amounts grouped by vendor and supplier:

```sql
SELECT * FROM Purchase_Summary;
```

### Transaction Isolation
The session isolation level is set to `READ COMMITTED` to prevent dirty reads.

---

## File Structure

```
vendor_supplier_db.sql   # Full database setup script
README.md                # This file
```
