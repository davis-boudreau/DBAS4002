## 🏥 **Healthcare**

### **INNER JOIN**
**Use Case:** Find patients who have scheduled appointments.

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
INNER JOIN Appointments ON Patients.ID = Appointments.PatientID;
```
**Venn Representation:** `A ∩ B`  
!alt text

---

### **LEFT JOIN**
**Use Case:** List all patients, including those who haven’t scheduled an appointment.

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
LEFT JOIN Appointments ON Patients.ID = Appointments.PatientID;
```
**Venn Representation:** `A ⟶ A ∪ B (with NULLs from B)`  
!alt text

---

### **RIGHT JOIN**
**Use Case:** Show all appointments, even if the patient record is missing.

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
RIGHT JOIN Appointments ON Patients.ID = Appointments.PatientID;
```
**Venn Representation:** `B ⟶ A ∪ B (with NULLs from A)`  
!alt text

---

### **FULL OUTER JOIN**
**Use Case:** Audit all patients and appointments, including unmatched records.

```sql
SELECT Patients.Name, Appointments.Date
FROM Patients
FULL OUTER JOIN Appointments ON Patients.ID = Appointments.PatientID;
```
**Venn Representation:** `A ∪ B`  
!alt text

---
