-- BUSINESS QUESTIONS
-- 1. How many doctors work in each department?
-- 2. How many appointments were scheduled, completed, and cancelled in each department?
-- 3. Which patients are currently admitted and have not been discharged yet?
-- 4. What is the total revenue collected from paid bills per department, grouped by payment method?
-- 5. How many staff members work in each role across all departments?
-- 6. Which medicines have been prescribed the most overall?
-- 7. What is the average number of appointments per patient in the last 6 months?
-- 8. Which doctors have the highest patient load, and how does it compare to their average working hours per day?
-- 9. What is the total revenue generated from different departments over the past quarter?
-- 10. Which are the top 5 most prescribed medicines in the last 3 months?
-- 11. What percentage of rooms (ICU, General, Private) were occupied in the last month?
-- 12. What is the cancellation rate per department over the past year?
-- 13. Which medicines have high prescription demand but low stock levels?
-- 14. What is the average length of stay per room type, and which type has the longest stays?
-- 15. Which patients had more than 3 appointments in the last year, and how many different doctors did they see?

-- RELEVANT QUERIES
-- 1. How many doctors work in each department?
SELECT dep.DepartmentName, Count(d.DoctorID) AS DoctorCount
FROM Doctor d
JOIN Department dep ON d.DepartmentID = dep.DepartmentID
GROUP BY dep.DepartmentName
ORDER BY DoctorCount DESC;

-- 2. How many appointments were scheduled, completed, and cancelled in each department?
SELECT dep.DepartmentName,
       SUM(CASE WHEN a.Status = 'Scheduled' THEN 1 ELSE 0 END) AS Scheduled,
       SUM(CASE WHEN a.Status = 'Completed' THEN 1 ELSE 0 END) AS Completed,
       SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled
FROM Appointment a
JOIN Department dep ON a.DepartmentID = dep.DepartmentID
GROUP BY dep.DepartmentName
ORDER BY dep.DepartmentName;

-- 3. Which patients are currently admitted and have not been discharged yet?
SELECT p.FirstName, p.LastName, r.RoomNumber, r.RoomType, ra.AdmissionDate
FROM RoomAssignment ra
JOIN Patient p ON ra.PatientID = p.PatientID
JOIN Room r ON ra.RoomID = r.RoomID
WHERE ra.DischargeDate IS NULL
ORDER BY ra.AdmissionDate;

-- 4. What is the total revenue collected from paid bills per department, grouped by payment method?
SELECT dep.DepartmentName, b.PaymentMethod,
       COUNT(b.BillingID) AS BillCount,
       SUM(b.TotalAmount) AS TotalRevenue
FROM Billing b
JOIN Appointment a ON b.PatientID = a.PatientID
JOIN Department dep ON a.DepartmentID = dep.DepartmentID
WHERE b.PaymentStatus = 'Paid'
GROUP BY dep.DepartmentName, b.PaymentMethod
ORDER BY dep.DepartmentName, TotalRevenue DESC;

-- 5. How many staff members work in each role across all departments?
SELECT dep.DepartmentName, s.Role, COUNT(s.StaffID) AS StaffCount
FROM Staff s
JOIN Department dep ON s.DepartmentID = dep.DepartmentID
GROUP BY dep.DepartmentName, s.Role
ORDER BY dep.DepartmentName, StaffCount DESC;

-- 6. Which medicines have been prescribed the most overall?
SELECT m.MedicineName, m.Manufacturer,
       COUNT(pr.PrescriptionID) AS TimesPrescribed
FROM Prescription pr
JOIN Medicine m ON pr.MedicineID = m.MedicineID
GROUP BY m.MedicineName, m.Manufacturer
ORDER BY TimesPrescribed DESC;

-- 7. What is the average number of appointments per patient in the last 6 months?
SELECT AVG(PatientAppointments) AS AvgAppointmentsPerPatient
FROM (
    SELECT p.PatientID, COUNT(a.AppointmentID) AS PatientAppointments
    FROM Patient p
    JOIN Appointment a ON p.PatientID = a.PatientID
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY p.PatientID
) AS PatientCounts;

-- 8. Which doctors have the highest patient load, and how does it compare to their availability?
SELECT d.FirstName, d.LastName, d.Specialization, d.Availability,
       COUNT(a.AppointmentID) AS TotalAppointments,
       COUNT(DISTINCT a.PatientID) AS UniquePatients
FROM Doctor d
JOIN Appointment a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.FirstName, d.LastName, d.Specialization, d.Availability
ORDER BY TotalAppointments DESC;

-- 9. What is the total revenue generated from different departments over the past quarter?
SELECT dep.DepartmentName,
       COUNT(b.BillingID) AS TotalBills,
       SUM(b.TotalAmount) AS TotalRevenue
FROM Billing b
JOIN Appointment a ON b.PatientID = a.PatientID
JOIN Department dep ON a.DepartmentID = dep.DepartmentID
WHERE b.PaymentDate >= DATEADD(QUARTER, -1, '2025-03-31')
GROUP BY dep.DepartmentName
ORDER BY TotalRevenue DESC;

-- 10. Which are the top 5 most prescribed medicines in the last 3 months?
SELECT TOP 5 m.MedicineName, COUNT(pr.PrescriptionID) AS TimesPrescribed
FROM Prescription pr
JOIN Medicine m ON pr.MedicineID = m.MedicineID
JOIN MedicalRecord mr ON pr.RecordID = mr.RecordID
WHERE mr.VisitDate >= DATEADD(MONTH, -3, '2025-03-31')
GROUP BY m.MedicineName
ORDER BY TimesPrescribed DESC;

-- 11. What percentage of rooms (ICU, General, Private) were occupied in the last month?
SELECT r.RoomType,
       COUNT(r.RoomID) AS TotalRooms,
       SUM(CASE WHEN ra.AssignmentID IS NOT NULL THEN 1 ELSE 0 END) AS OccupiedRooms,
       SUM(CASE WHEN ra.AssignmentID IS NOT NULL THEN 1 ELSE 0 END) * 100.0
           / COUNT(r.RoomID) AS OccupancyPercent
FROM Room r
LEFT JOIN RoomAssignment ra ON r.RoomID = ra.RoomID
    AND ra.AdmissionDate <= GETDATE()
    AND (ra.DischargeDate IS NULL OR ra.DischargeDate >= DATEADD(MONTH, -1, GETDATE()))
WHERE r.RoomType IN ('ICU', 'General', 'Private')
GROUP BY r.RoomType
ORDER BY OccupancyPercent DESC;

-- 12. What is the cancellation rate per department over the past year?
SELECT dep.DepartmentName,
       COUNT(a.AppointmentID) AS TotalAppointments,
       SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
       SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0
           / COUNT(a.AppointmentID) AS CancellationRate
FROM Appointment a
JOIN Department dep ON a.DepartmentID = dep.DepartmentID
WHERE a.AppointmentDate >= DATEADD(YEAR, -1, GETDATE())
GROUP BY dep.DepartmentName
ORDER BY CancellationRate DESC;

-- 13. Which medicines have high prescription demand but low stock levels?
SELECT m.MedicineName, m.StockQuantity,
       COUNT(pr.PrescriptionID) AS TimesPrescribed
FROM Prescription pr
JOIN Medicine m ON pr.MedicineID = m.MedicineID
JOIN MedicalRecord mr ON pr.RecordID = mr.RecordID
WHERE mr.VisitDate >= DATEADD(MONTH, -6, '2025-03-31')
GROUP BY m.MedicineID, m.MedicineName, m.StockQuantity
HAVING COUNT(pr.PrescriptionID) > 10 AND m.StockQuantity < 3000
ORDER BY TimesPrescribed DESC;

-- 14. What is the average length of stay per room type, and which type has the longest stays?
SELECT r.RoomType,
       COUNT(ra.AssignmentID) AS TotalAdmissions,
       AVG(DATEDIFF(DAY, ra.AdmissionDate,
           ISNULL(ra.DischargeDate, GETDATE()))) AS AvgStayDays
FROM RoomAssignment ra
JOIN Room r ON ra.RoomID = r.RoomID
GROUP BY r.RoomType
ORDER BY AvgStayDays DESC;

-- 15. Which patients had more than 3 appointments in the last year, and how many different doctors did they see?
SELECT p.FirstName, p.LastName,
       COUNT(a.AppointmentID) AS TotalAppointments,
       COUNT(DISTINCT a.DoctorID) AS DifferentDoctors
FROM Patient p
JOIN Appointment a ON p.PatientID = a.PatientID
WHERE a.AppointmentDate >= DATEADD(YEAR, -1, GETDATE())
GROUP BY p.PatientID, p.FirstName, p.LastName
HAVING COUNT(a.AppointmentID) > 3
ORDER BY TotalAppointments DESC;


