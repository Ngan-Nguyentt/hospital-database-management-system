# Hospital Database Management System

A normalised **SQL Server** database for end-to-end hospital operations — patients, doctors, staff,
appointments, medical records, prescriptions, billing, medicines, and room assignments — with
**role-based security**, **15 business-question queries**, and a **Power BI** dashboard built on top for
operational reporting.

> Course: Database Design · Algonquin College · Business Intelligence Systems Infrastructure

---

## 🎯 Objective
Model a hospital's operations in a clean relational schema, enforce data integrity, and answer real
operational questions (revenue, capacity, retention, stock risk) that managers can act on.

## 🗄️ Database design
- **11 normalised tables (3NF)** with enforced **primary / foreign keys** and **CHECK / DEFAULT / UNIQUE**
  constraints:
  `Department`, `Patient`, `Doctor`, `Appointment`, `MedicalRecord`, `Medicine`, `Prescription`,
  `Billing`, `Staff`, `Room`, `RoomAssignment`.
- **Role-based, least-privilege access** (admin & user roles) in `13-create-users-roles.sql`.

## ❓ Business questions (15)
Answered in `14-business-queries.sql` using multi-table JOINs, subqueries, and CASE logic — for example:
- Appointments scheduled / completed / cancelled per department, and **cancellation rate** per department.
- **Average appointments per patient** over the last 6 months (retention).
- **Revenue** by department and payment method.
- **Room occupancy** by type (ICU / General / Private) and **average length of stay**.
- **Medicines with high prescription demand but low stock** (shortage risk).
- Top-prescribed medicines, busiest doctors vs. working hours, and more.

## 📊 Power BI dashboard
`hospital-database-report.pbix` (static export: `hospital-database-report.pdf`) turns the data into an
operational screen tracking, for the sample data:
- **$1.77M** revenue · **3.50** appointments per patient · **18.0%** cancellation rate · **62.5%** room occupancy.
- A live **stock-status table** flagging critical medicines (e.g. *Insulin Glargine, Warfarin, Digoxin*)
  before they run out.

## 🛠️ Tech stack
`Microsoft SQL Server` · `T-SQL` · relational modelling (3NF, ERD) · `Power BI`

## 📁 Repository structure & run order
Run the scripts in numbered order against a SQL Server instance:
```
01-create-tables.sql           # schema: 11 tables, keys & constraints
02-…-12-…-insert-*.sql         # seed data: departments, patients, doctors, appointments, records,
                               #   medicines, prescriptions, billing, staff, rooms, room assignments
13-create-users-roles.sql      # role-based access (admin & users)
14-business-queries.sql        # 15 analytical business questions
hospital-database-report.pbix  # Power BI dashboard
hospital-database-report.pdf   # static export of the dashboard
README.md
```

## ▶️ How to run
1. Create a database in **SQL Server** (e.g. `HospitalDB`).
2. Execute `01` → `12` in order to build the schema and load the seed data.
3. Run `13-create-users-roles.sql` to set up roles, then `14-business-queries.sql` for the analysis.
4. Open `hospital-database-report.pbix` in **Power BI Desktop** to explore the dashboard.

## 👥 Authors
Team project — **Ngan Nguyen** · **Duc Anh Ngo** · **DongHwan Won**
Business Intelligence Systems Infrastructure, Algonquin College

🔗 Portfolio: **https://ngan-nguyentt.github.io/**
