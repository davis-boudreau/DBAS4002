## 🏥 **Healthcare**

### **INNER JOIN**

**Use Case:** Find patients who have scheduled appointments.
**SQL:**

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
INNER JOIN Appointments ON Patients.ID = Appointments.PatientID;
```

**Relational Algebra:**

$$
Patients \bowtie_{Patients.ID = Appointments.PatientID} Appointments
$$

**Venn Representation:** `A ∩ B`
![alt text](image-1.png)

---

### **LEFT JOIN**

**Use Case:** List all patients, including those who haven’t scheduled an appointment.
**SQL:**

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
LEFT JOIN Appointments ON Patients.ID = Appointments.PatientID;
```

**Relational Algebra:**

$$
Patients \ \text{⟕}_{Patients.ID = Appointments.PatientID} \ Appointments
$$

**Venn Representation:** `A ⟶ A ∪ B (with NULLs from B)`
![alt text](image-2.png)

---

### **RIGHT JOIN**

**Use Case:** Show all appointments, even if the patient record is missing.
**SQL:**

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
RIGHT JOIN Appointments ON Patients.ID = Appointments.PatientID;
```

**Relational Algebra:**

$$
Patients \ \text{⟖}_{Patients.ID = Appointments.PatientID} \ Appointments
$$

**Venn Representation:** `B ⟶ A ∪ B (with NULLs from A)`
![alt text](image-3.png)

---

### **FULL OUTER JOIN**

**Use Case:** Audit all patients and appointments, including unmatched records.
**SQL:**

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
FULL OUTER JOIN Appointments ON Patients.ID = Appointments.PatientID;
```

**Relational Algebra:**

$$
Patients \ \text{⟗}_{Patients.ID = Appointments.PatientID} \ Appointments
$$

**Venn Representation:** `A ∪ B`
![alt text](image-4.png)

---

## 🛒 **Retail / E-commerce**

### **INNER JOIN**

**Use Case:** Get customers who placed orders.
**SQL:**

```sql
SELECT Customers.Name, Orders.OrderDate
FROM Customers
INNER JOIN Orders ON Customers.ID = Orders.CustomerID;
```

**Relational Algebra:**

$$
Customers \bowtie_{Customers.ID = Orders.CustomerID} Orders
$$

![alt text](image-1.png)

---

### **LEFT JOIN**

**Use Case:** List all customers, including those who haven’t placed any orders.
**SQL:**

```sql
SELECT Customers.Name, Orders.OrderDate
FROM Customers
LEFT JOIN Orders ON Customers.ID = Orders.CustomerID;
```

**Relational Algebra:**

$$
Customers \ \text{⟕}_{Customers.ID = Orders.CustomerID} \ Orders
$$

![alt text](image-2.png)

---

### **RIGHT JOIN**

**Use Case:** Show all orders, even if customer data is incomplete.
**SQL:**

```sql
SELECT Customers.Name, Orders.OrderDate
FROM Customers
RIGHT JOIN Orders ON Customers.ID = Orders.CustomerID;
```

**Relational Algebra:**

$$
Customers \ \text{⟖}_{Customers.ID = Orders.CustomerID} \ Orders
$$

![alt text](image-3.png)

---

### **FULL OUTER JOIN**

**Use Case:** Combine customer and order data for a full report, including gaps.
**SQL:**

```sql
SELECT Customers.Name, Orders.OrderDate
FROM Customers
FULL OUTER JOIN Orders ON Customers.ID = Orders.CustomerID;
```

**Relational Algebra:**

$$
Customers \ \text{⟗}_{Customers.ID = Orders.CustomerID} \ Orders
$$

![alt text](image-4.png)

---

## 🎓 **Education / Academic**

### **INNER JOIN**

**Use Case:** Find students who are enrolled in courses.
**SQL:**

```sql
SELECT Students.Name, Enrollments.CourseID
FROM Students
INNER JOIN Enrollments ON Students.ID = Enrollments.StudentID;
```

**Relational Algebra:**

$$
Students \bowtie_{Students.ID = Enrollments.StudentID} Enrollments
$$

![alt text](image-1.png)

---

### **LEFT JOIN**

**Use Case:** List all students, including those not enrolled in any course.
**SQL:**

```sql
SELECT Students.Name, Enrollments.CourseID
FROM Students
LEFT JOIN Enrollments ON Students.ID = Enrollments.StudentID;
```

**Relational Algebra:**

$$
Students \ \text{⟕}_{Students.ID = Enrollments.StudentID} \ Enrollments
$$

![alt text](image-2.png)

---

### **RIGHT JOIN**

**Use Case:** Show all courses, even if no students are enrolled.
**SQL:**

```sql
SELECT Students.Name, Courses.Title
FROM Students
RIGHT JOIN Enrollments ON Students.ID = Enrollments.StudentID
RIGHT JOIN Courses ON Enrollments.CourseID = Courses.ID;
```

**Relational Algebra:**

$$
(Students \ \text{⟕}_{Students.ID = Enrollments.StudentID} Enrollments) \ \text{⟖}_{Enrollments.CourseID = Courses.ID} \ Courses
$$

![alt text](image-3.png)

---

### **FULL OUTER JOIN**

**Use Case:** Full academic audit of students and courses.
**SQL:**

```sql
SELECT Students.Name, Courses.Title
FROM Students
FULL OUTER JOIN Enrollments ON Students.ID = Enrollments.StudentID
FULL OUTER JOIN Courses ON Enrollments.CourseID = Courses.ID;
```

**Relational Algebra:**

$$
(Students \ \text{⟗}_{Students.ID = Enrollments.StudentID} Enrollments) \ \text{⟗}_{Enrollments.CourseID = Courses.ID} \ Courses
$$

![alt text](image-4.png)

---

## ✅ **SQL ↔ Relational Algebra ↔ Venn Diagram Cheat Sheet**

| **Join Type**       | **SQL Syntax**                                         | **Relational Algebra**          | **Venn Diagram / Concept**                                                                                   |
| ------------------- | ------------------------------------------------------ | ------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **INNER JOIN**      | `SELECT ... FROM A INNER JOIN B ON A.ID = B.AID;`      | $A \bowtie_{A.ID=B.AID} B$      | 🔵⚫ Overlap only (`A ∩ B`) <br> ![A∩B](https://via.placeholder.com/50x30?text=A∩B)                           |
| **LEFT JOIN**       | `SELECT ... FROM A LEFT JOIN B ON A.ID = B.AID;`       | $A \ \text{⟕}_{A.ID=B.AID} \ B$ | 🔵 All of A + matched B (`A ∪ matched B`) <br> ![A LEFT B](https://via.placeholder.com/50x30?text=A+LEFT+B)  |
| **RIGHT JOIN**      | `SELECT ... FROM A RIGHT JOIN B ON A.ID = B.AID;`      | $A \ \text{⟖}_{A.ID=B.AID} \ B$ | ⚫ All of B + matched A (`B ∪ matched A`) <br> ![A RIGHT B](https://via.placeholder.com/50x30?text=A+RIGHT+B) |
| **FULL OUTER JOIN** | `SELECT ... FROM A FULL OUTER JOIN B ON A.ID = B.AID;` | $A \ \text{⟗}_{A.ID=B.AID} \ B$ | 🔵⚫ Everything from A and B (`A ∪ B`) <br> ![A FULL B](https://via.placeholder.com/50x30?text=A+FULL+B)      |

> 🔹 **Legend for colors**:
> 🔵 = Table A
> ⚫ = Table B

