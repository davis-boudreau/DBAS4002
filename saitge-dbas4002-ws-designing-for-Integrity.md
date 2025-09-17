# Workshop: *Designing for Integrity – ER Modeling, Normalization & DDL*

## 1. Tutorial: Understanding the Dataset

We are given the following **flat table**:

```
ID, AssetLabel, LocationName, DepartmentName, SupportVendorName, 
Product Number, Manufacturer, Part Number, Product Description, 
Purchase Date, Installed Date, Comments, Cost, Asset Number, Serial Number
```

This table mixes **assets, vendors, departments, and locations** into a single structure. At first glance, it *works* for recording data — but it has issues:

* **Data redundancy** (e.g., same `LocationName` or `Manufacturer` repeated for many rows).
* **Update anomalies** (if vendor’s name changes, must update in many places).
* **Insert anomalies** (cannot record a new `SupportVendor` unless an asset exists).
* **Delete anomalies** (removing an asset may remove knowledge of a `Department`).

Our goal is to **design a database for integrity**: eliminate redundancy, reduce anomalies, and enforce constraints.

---

## 2. Step 1 – ER Modeling

### Activity (Group Work)

**Task:** Identify entities and relationships.

From the table, possible **entities**:

* **Asset** (AssetLabel, Asset Number, Serial Number, Cost, Purchase/Installed Dates, Comments).
* **Location** (LocationName).
* **Department** (DepartmentName).
* **SupportVendor** (SupportVendorName).
* **Product** (Product Number, Manufacturer, Part Number, Description).

### Relationships:

* An **Asset** is assigned to a **Location**.
* An **Asset** belongs to a **Department**.
* An **Asset** is supported by a **Vendor**.
* An **Asset** is of a particular **Product**.

**Hands-on:** Teams draw an ER diagram showing these entities, their attributes, primary keys, and relationships (with cardinalities).

---

## 3. Step 2 – Normalization

We’ll take the flat table and normalize it progressively:

### 1NF – Remove repeating groups, ensure atomic values

Our table is already atomic (each field has a single value), so 1NF is satisfied.

### 2NF – Remove partial dependency (fields depending only on part of a composite key)

If we had a composite key (e.g., `AssetLabel + Product Number`), dependencies would be an issue. Instead, we should separate independent entities.

* Split **Product details** (Product Number, Manufacturer, Part Number, Description) into a **Product table**.
* Split **SupportVendorName** into its own table.
* Split **DepartmentName** and **LocationName** into their own tables.

### 3NF – Remove transitive dependencies

* Ensure non-key attributes only depend on the primary key.
* Example: `Manufacturer` belongs with `Product`, not with `Asset`.

**Resulting schema:**

* **Asset(AssetID, AssetLabel, AssetNumber, SerialNumber, Cost, PurchaseDate, InstalledDate, Comments, LocationID, DepartmentID, VendorID, ProductID)**
* **Location(LocationID, LocationName)**
* **Department(DepartmentID, DepartmentName)**
* **Vendor(VendorID, VendorName)**
* **Product(ProductID, ProductNumber, Manufacturer, PartNumber, Description)**

---

## 4. Step 3 – DDL Implementation

Now, translate normalized schema into SQL **DDL**.

```sql
CREATE TABLE Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    LocationName VARCHAR(100) NOT NULL
);

CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Vendor (
    VendorID INT PRIMARY KEY AUTO_INCREMENT,
    VendorName VARCHAR(100) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductNumber VARCHAR(50) NOT NULL,
    Manufacturer VARCHAR(100),
    PartNumber VARCHAR(50),
    Description TEXT
);

CREATE TABLE Asset (
    AssetID INT PRIMARY KEY AUTO_INCREMENT,
    AssetLabel VARCHAR(50),
    AssetNumber VARCHAR(50),
    SerialNumber VARCHAR(50),
    Cost DECIMAL(10,2),
    PurchaseDate DATE,
    InstalledDate DATE,
    Comments TEXT,
    LocationID INT,
    DepartmentID INT,
    VendorID INT,
    ProductID INT,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (VendorID) REFERENCES Vendor(VendorID),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
```

---

## 5. Practical Workshop Flow

### **Activity 1: ER Modeling (45 min)**

* Participants analyze CSV → identify entities.
* Draw ER diagrams in groups.
* Present & compare results.

### **Activity 2: Normalization (45 min)**

* Start with flat CSV table.
* Step-by-step normalize (1NF → 3NF).
* Groups rewrite schema.

### **Activity 3: DDL Implementation (60 min)**

* Translate schema into SQL `CREATE TABLE`.
* Implement foreign keys, constraints.
* Test by inserting sample records.

### **Wrap-up (15 min)**

* Discuss how normalization improved integrity.
* Reflect on common mistakes.

---

At the end, each group will have:

1. An **ER diagram**.
2. A **normalized schema**.
3. A working **SQL DDL script**.

---
