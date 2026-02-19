Use Hosipatel_System


------------ Patient City ----------- 

Alter table [dbo].[Patients]
Add city varchar(100)

Update [dbo].[Patients] set city = 'Dallas' where insurancename = 'Aetna'
Update [dbo].[Patients] set city = 'Chicago' where insurancename = 'BlueCross'
Update [dbo].[Patients] set city = 'Detroit' where insurancename = 'Cigna'
Update [dbo].[Patients] set city = 'Houston' where insurancename = 'United'

--- Retrieve all records from the Patients table.

Select *from [dbo].[Patients]

---- Display PatientID, FirstName, LastName, City for patients living in Dallas.

Select patientid,firstname,lastname from [dbo].[Patients] where city = 'Dallas'

----- List all doctors along with their specialization.

Select *from [dbo].[Doctors]

-------- Find all appointments with Status = 'Scheduled'.

Select *from [dbo].[Appointments]

-------- Show all bills where BillStatus = 'Pending'.

Select *from [dbo].[Bills] where billstatus ='Pending'

---- Retrieve distinct cities from the Patients table.

Select Distinct City from [dbo].[Patients]

---- Count the total number of doctors in the hospital.

Select Count(DoctorID) as Dcotorname from [dbo].[Doctors]


----- Display all departments with a budget greater than 500000.

Select *from [dbo].[Departments] where [Budget] >500000

----- Fetch appointments scheduled on '2023-01-10'.

Select *from appointments where [AppointmentDate] = '2024-01-10'

---- List all active medications (IsActive = 1).

Select *from [dbo].[Medications] where isactive = 'Y'

------ Joins -------------------------------
------------------ Tables --------------------------------------

Select top 1* from [dbo].[Appointments]
Select top 1* from [dbo].[Departments]
Select top 1* from [dbo].[Bills]
Select top 1* from [dbo].[Doctor_Shifts]
Select top 1* from [dbo].[Doctors]
Select top 1* from [dbo].[Insurance_Claims]
Select top 1* from [dbo].[Insurance_Providers]
Select top 1* from [dbo].[Medical_Records]
Select top 1* from [dbo].[MedicationInventory]
Select top 1* from [dbo].[Medications]
Select top 1* from [dbo].[Patient_Insurance]
Select top 1* from [dbo].[Patients]
Select top 1* from [dbo].[Payments]
Select * from [dbo].[Medical_Records]


SELECT *
FROM INFORMATION_SCHEMA.TABLES


------------ Joins -------------------- 

/* Create a comprehensive patient treatment report showing diagnosis, treatment, and prescribed medications.*/ 

Select p.patientid,
P.FirstName+' '+P.LastName as Patientname,
P.DateOfBirth,
D.Doctorname, 
mr.Recorddate,
Mr.Diagnosis,
[medication_id],
mr.Treatment
from Patients P Join Appointments A ON A.Patientid = P.Patientid 
Join Doctors D on D.Doctorid = A.Doctorid Join 
[dbo].[Treatment_table] MR on Mr.Patientid = P.PatientID



/* Identify all bills and their payment status, including bills with no payments */ 

SELECT b.billid, 
P.FirstName+' '+P.LastName as Patientname, 
b.totalamount,
b.billdate, 
b.billstatus AS bill_status,
COALESCE(SUM(pay.paidamount), 0)
--(b.totalamount - COALESCE(SUM(pay.paidamount), 0) AS balance 
FROM Bills b INNER JOIN Patients p 
ON b.patientid = p.patientid LEFT JOIN Payments pay ON b.billid = pay.billid 
where B.BillStatus ='pending'
GROUP BY b.billid,P.FirstName+' '+P.LastName ,b.totalamount, b.billdate, b.billstatus 

------ Subqueires  ----------------------------------------

---- Scenario: Identify all appointments for patients who have any unpaid bills in the system.------------
---- Business Use: Send appointment reminders only to patients with outstanding payments

Select top 1*from [dbo].[Appointments]
Select  *from [dbo].[Bills]

Select *from  [dbo].[Appointments]
where PatientID  in (Select patientid from Bills where BillStatus !='paid'  )
Select *from  [dbo].[Appointments]
where PatientID  Not in (Select patientid from Bills where BillStatus ='paid'  )


 ----- Find patients whose total billing amount exceeds the hospital's average patient billing.

 Select top 1* from DBO.Patients
  Select top 1* from DBO.Bills

 
 Select P.patientid,P.FirstName,p.LastName,p.city,Sum(b.TotalAmount) as total_bills
 from Patients P Join Bills B on P.patientid =B.patientid 
 group by P.patientid,P.FirstName,p.LastName,p.city
 having Sum(b.TotalAmount) > all (Select Avg(totalamount) from BIlls B)
 order by  total_bills

 SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    p.City,
    PatientBills.TotalBilled

FROM Patients p
INNER JOIN (
    SELECT 
        b.PatientID,
        SUM(b.TotalAmount) AS TotalBilled,
        COUNT(b.BillID) AS AppointmentCount
    FROM Bills b
    GROUP BY b.PatientID
    HAVING SUM(b.TotalAmount) > (
        SELECT AVG(PatientTotal)
        FROM (
            SELECT SUM(TotalAmount) AS PatientTotal
            FROM Bills
            GROUP BY PatientID
        ) AS AvgCalc
    )
) AS PatientBills ON p.PatientID = PatientBills.PatientID
ORDER BY PatientBills.TotalBilled 

/* Business Use: Identify VIP patients for personalized care programs or loyalty benefits */

------------------ Set operators ------------------------- 

-- Scenario 1: UNION - Combine high-risk patients

SELECT 
    'Elderly Patients' AS RiskCategory,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    p.City,
    COUNT(DISTINCT a.AppointmentID) AS TotalVisits
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
WHERE DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) >= 50
GROUP BY 
    p.PatientID, p.FirstName, p.LastName, 
    p.DateOfBirth, p.City

UNION

SELECT 
    'Chronic Conditions' AS RiskCategory,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    p.City,
    COUNT(DISTINCT a.AppointmentID) AS TotalVisits
FROM Patients p
INNER JOIN Medical_Records mr 
    ON p.PatientID = mr.PatientID
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
WHERE mr.Diagnosis LIKE '%Diabetes%'
   OR mr.Diagnosis LIKE '%Hypertension%'
   OR mr.Diagnosis LIKE '%Heart%'
   OR mr.Diagnosis LIKE '%Cancer%'
GROUP BY 
    p.PatientID, p.FirstName, p.LastName, 
    p.DateOfBirth, p.City

UNION

SELECT 
    'Frequent Visitors' AS RiskCategory,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) AS Age,
    p.City,
    COUNT(DISTINCT a.AppointmentID) AS TotalVisits
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
WHERE a.AppointmentDate >= DATEADD(YEAR, -1, GETDATE())
GROUP BY 
    p.PatientID, p.FirstName, p.LastName, 
    p.DateOfBirth, p.City
HAVING COUNT(DISTINCT a.AppointmentID) > 10

ORDER BY RiskCategory, TotalVisits DESC;


---- UNION ALL ----------------------- 

-- Scenario 2: UNION ALL

SELECT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    'Cardiology' AS Department,
    a.AppointmentDate AS VisitDate,
    a.Status,
    d.DoctorName
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName = 'Cardiology'
  --AND a.AppointmentDate >= DATEADD(MONTH, -3, GETDATE())

UNION ALL

SELECT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    'Oncology' AS Department,
    a.AppointmentDate AS VisitDate,
    a.Status,
    d.DoctorName
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName = 'Oncology'
  --AND a.AppointmentDate >= DATEADD(MONTH, -3, GETDATE())

ORDER BY PatientID, VisitDate DESC;


--------------- Intersect ---------------------------- 

-- Scenario 3: INTERSECT

SELECT DISTINCT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName = 'Cardiology'

INTERSECT

SELECT DISTINCT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName =('oncology')



---- Except ------------------------ 


-- Scenario 4: EXCEPT

SELECT 
    'Emergency Only' AS PatientType,
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    COUNT(a.AppointmentID) AS EmergencyVisits,
    MAX(a.AppointmentDate) AS LastVisit
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName = 'Emergency'
GROUP BY p.PatientID, p.FirstName, p.LastName

EXCEPT

SELECT 
    'Emergency Only',
    p.PatientID,
    p.FirstName + ' ' + p.LastName,
    COUNT(a.AppointmentID),
    MAX(a.AppointmentDate)
FROM Patients p
INNER JOIN Appointments a 
    ON p.PatientID = a.PatientID
INNER JOIN Doctors d 
    ON a.DoctorID = d.DoctorID
INNER JOIN Departments dept 
    ON d.DepartmentID = dept.DepartmentID
WHERE dept.DepartmentName <> 'Emergency'
GROUP BY p.PatientID, p.FirstName, p.LastName;


----- Views ----------------------------------- 


/* Use Case Scenario: The hospital receptionist needs to quickly access basic patient information without seeing 
-sensitive medical data. Creating a view will simplify their queries and protect patient privacy by only showing 
necessary information */

CREATE or Alter VIEW V_PatientBasicInfo AS
SELECT 
    PatientID,
    FirstName,
    LastName,
    Gender,
    Phone,
    City
FROM Patients;


/* The appointment scheduling system needs to quickly identify which doctors are available for morning shifts. 
Instead of writing complex queries every time, we create a view that shows doctors with their active morning shifts */

Create or alter View VW_Doctor_Avaliblity 
AS
Select 
D.DoctorID,D.DoctorName,D.Specialization,D.phone,S.Shiftdate,S.Status,s.StartTime,S.endtime
from [dbo].[Doctors] D join [dbo].[Doctor_Shifts] S
on D.DoctorID = S.DoctorID
where S.ShiftType ='Morning' and S.status='Active'

Select *from VW_Doctor_Avaliblity where Shiftdate >=GETDATE()


/* Dangling View * A hospital creates a view on a temporary lookup table for insurance providers. 
When the table is dropped to update the structure, 
the view becomes dangling and will throw errors when queried */ 

-- Create a view on this table
CREATE or alter VIEW V_InsuranceList AS
SELECT 
    ProviderID,
    ProviderName,
    ContactPhone
FROM [dbo].[Insurance_Providers];

-- Query the view successfully
SELECT * FROM V_InsuranceList;



Select *from Sys.objects where name ='V_InsuranceList' --- This view is Dropped object View 


----- Permission changes ------The Permission of base tables which is referenced by view is modifled or revoked this is also called dabgling view and garbage view 


--------------- Schema Binding View ----------------------- 

/* The hospital wants to create a critical view for billing reports that must always be available. 
Using SCHEMABINDING prevents anyone from accidentally dropping or modifying the underlying table columns */

CREATE TABLE MedicationInventory (
    InventoryID INT PRIMARY KEY,
    MedicationName VARCHAR(100),
    Quantity INT,
    ReorderLevel INT,
    LastRestockDate DATE
);

-- Insert sample data
INSERT INTO MedicationInventory VALUES
(1, 'Aspirin', 500, 100, '2024-01-15'),
(2, 'Ibuprofen', 300, 50, '2024-01-10');

Select *from MedicationInventory

CREATE VIEW V_LowStockMedications WITH SCHEMABINDING
AS
SELECT 
    InventoryID,
    MedicationName,
    Quantity,
    ReorderLevel
FROM dbo.MedicationInventory  -- Must use two-part name (schema.table)
WHERE Quantity <= ReorderLevel;

-- Query the view
SELECT * FROM V_LowStockMedications

---- THIS FAILS - Cannot drop column used by schema-bound view
ALTER TABLE MedicationInventory
DROP COLUMN ReorderLevel;

--Adding new columns is allowed
ALTER TABLE MedicationInventory
ADD Supplier VARCHAR(100);

-- Dropping columns NOT used by the view is allowed
ALTER TABLE MedicationInventory
DROP COLUMN LastRestockDate;  -- This column is not in the view

--TRUNCATE is allowed (only deletes data, not structure)
TRUNCATE TABLE MedicationInventory;

------------ Temporary tables --------------- 

----------- write a query to find the patient billing analysis -----------
CREATE TABLE #PatientBillingAnalysis
(
    PatientID INT,
    PatientName VARCHAR(200),
    BillID INT,
    TotalAmount DECIMAL(10,2),
    InsuranceProvider VARCHAR(100),
    CoveragePercent DECIMAL(5,2),
    InsuranceCoverage DECIMAL(10,2),
    PatientResponsibility DECIMAL(10,2),
    PaidAmount DECIMAL(10,2),
    OutstandingBalance DECIMAL(10,2),
    BillStatus VARCHAR(50),
    DaysPastDue INT,
    CollectionPriority VARCHAR(20)
);

Select *from [dbo].[Insurance_Providers]

Select top 1* from [dbo].[Bills]
---- Inserting the billing data --------------- 
INSERT INTO #PatientBillingAnalysis
SELECT 
    p.PatientID,
    p.FirstName + ' ' + p.LastName AS PatientName,
    b.BillID,
    b.TotalAmount,

    ip.ProviderName AS InsuranceProvider,
    pi.CoveragePercent AS CoveragePercent,

    -- Insurance Coverage Calculation
    CASE 
        WHEN pi.CoveragePercent IS NOT NULL
            THEN b.TotalAmount * (pi.CoveragePercent / 100.0)
        ELSE 0
    END AS InsuranceCoverage,

    -- Patient Responsibility
    CASE 
        WHEN pi.CoveragePercent IS NOT NULL
            THEN b.TotalAmount * (1 - pi.CoveragePercent / 100.0)
        ELSE b.TotalAmount
    END AS PatientResponsibility,

    ISNULL(pay.PaidAmount, 0) AS PaidAmount,

    -- Outstanding Balance
    b.TotalAmount - ISNULL(pay.[PaidAmount], 0) AS OutstandingBalance,
    b.BillStatus,
    DATEDIFF(DAY, b.BillDate, GETDATE()) AS DaysPastDue,

    -- Collection Priority Logic
    CASE 
        WHEN DATEDIFF(DAY, b.BillDate, GETDATE()) > 90
             AND (b.TotalAmount - ISNULL(pay.PaidAmount, 0)) > 1000
            THEN 'Critical'
        WHEN DATEDIFF(DAY, b.BillDate, GETDATE()) > 60
             AND (b.TotalAmount - ISNULL(pay.PaidAmount, 0)) > 500
            THEN 'High'
        WHEN DATEDIFF(DAY, b.BillDate, GETDATE()) > 30
            THEN 'Medium'
        ELSE 'Low'
    END AS CollectionPriority

FROM Patients p
INNER JOIN Bills b
    ON p.PatientID = b.PatientID
LEFT JOIN Patient_Insurance pi
    ON p.PatientID = pi.PatientID
    AND GETDATE() BETWEEN pi.CoverageStartDate AND pi.CoverageEndDate
LEFT JOIN Insurance_Providers ip
    ON pi.ProviderID = ip.ProviderID
LEFT JOIN Payments Pay ON b.BillID = pay.BillID
WHERE b.BillStatus = 'pending';


Select *from  #PatientBillingAnalysis



------------ CTE --------------------------- 


---------------- RECRUISIVE Queries ----------------------------- 

/*==========================================================
  Query 1: Complete Doctor Hierarchy
==========================================================*/

WITH DoctorHierarchy AS
(
  
    SELECT
        d.DoctorID,
        d.DoctorName,
        d.Specialization,
        d.Phone,
        d.Email,
        d.Superviorid,
        dept.DepartmentName,
        dept.DepartmentID,
        0 AS HierarchyLevel
    FROM Doctors d
    INNER JOIN Departments dept
        ON d.DepartmentID = dept.DepartmentID
    WHERE d.Superviorid IS NULL OR d.Superviorid = 0

    UNION ALL

    SELECT
        d.DoctorID,
        d.DoctorName,
        d.Specialization,
        d.Phone,
        d.Email,
        d.Superviorid,
        dept.DepartmentName,
        dept.DepartmentID,
        dh.HierarchyLevel + 1
    FROM Doctors d
    INNER JOIN DoctorHierarchy dh
        ON d.Superviorid = dh.DoctorID
    INNER JOIN Departments dept
        ON d.DepartmentID = dept.DepartmentID
)

SELECT
    DoctorID,
    DoctorName AS OrganizationalChart,
    Specialization,
    DepartmentName,
  HierarchyLevel AS Level,
    Phone,
    Email
FROM DoctorHierarchy
OPTION (MAXRECURSION 100);


------------------ Table Variable ----------------

/* Use Case Scenario:
The hospital reception needs to process a subset of patient information for today's appointments.
Instead of querying the database multiple times, they load patient data into a table variable, 
perform calculations, and generate a check-in list */

Declare @patientinformation 
(
Patientid Int, 
Patientname varchar(100), 
Appointment 



/* The pharmacy needs to calculate which medications need reordering */ 



------- Scenario: Display today's schedule on doctor's dashboard --------------------------



Select *from Appointments
Select Appointmentid,Patientid, doctorid from 
Appointments where [AppointmentDate] ='2024-01-05'

Drop index  [PK__Appointm__8ECDFCA2F053CCC2]  on Appointments
Create Clustered index IX_Appointment_date on Appointments([AppointmentDate]) 

Select Appointmentid,Patientid, doctorid from 
Appointments where Appointmentid ='1001'

---- Composite index --------------------- 
/* Scenario: Show specific patient's appointments in chronological order */

SELECT * FROM Appointments 
WHERE patientid = 11 
ORDER BY [AppointmentDate] DESC

CREATE INDEX idx_patient_appointments 
ON Appointments(patientid, [AppointmentDate])

Sp_helpindex 'Appointments'

SELECT * FROM Appointments 
WHERE AppointmentID = 11 

SELECT * FROM Appointments 
WHERE AppointmentID = 1001 


CREATE TABLE Appointments2 (
    AppointmentID INT IDENTITY(1,1),
    PatientID INT,
    DoctorName VARCHAR(100),
    AppointmentDate DATETIME,
    Department VARCHAR(50),
    Status VARCHAR(20)
)


INSERT INTO Appointments2 (PatientID, DoctorName, AppointmentDate, Department, Status)
VALUES
(1, 'Dr. Sarah Johnson', '2024-02-20 10:00', 'Cardiology', 'Scheduled'),
(5, 'Dr. Michael Chen', '2024-02-20 11:00', 'Orthopedics', 'Scheduled'),
(3, 'Dr. Sarah Johnson', '2024-02-20 14:00', 'Cardiology', 'Scheduled'),
(8, 'Dr. David Rodriguez', '2024-02-21 09:00', 'Pediatrics', 'Scheduled'),
(2, 'Dr. Michael Chen', '2024-02-21 10:00', 'Orthopedics', 'Scheduled'


Select *from  Appointments2 
Select *from Appointments2 where Appointmentid=1
Select *from Appointments2 where Appointmentid=1
and PatientID=1
Select *from Appointments2 where
 PatientID=1
 Select patientid from Appointments2 where
 Appointmentid=1


 Sp_helpindex 'Appointments2'

Drop index IX_Appointmentp2 on Appointments2
Drop index IX_Appointments_P on Appointments2
Drop index IX_Appointments_DA on appointments2

Sp_helpindex 'Appointments2'

Create nonclustered index IX_Appointments_P on Appointments2 (Patientid)

Select doctorname , Department from Appointments2 where patientid=1  -------------- it must be Rowid lookup right 

Create nonclustered index IX_Appointments_DA on Appointments2 (Department)  include (Doctorname,Status)

Create clustered index IX_Appointments_A on Appointments2 (Appointmentid)

Select department,Appointmentid from Appointments2 where department ='Cardiology'

--------------------partition ----------------------------

Create Partition Function Partitionbyyear (DATE) 
as RANGE LEFT For Values ('2023-12-31','2024-12-31','2025-12-31')

Select *from Sys.partition_functions 

------ Fie groups --------------

Alter database Hosipatel_System add filegroup FG_2023
Alter database Hosipatel_System add filegroup FG_2024
Alter database Hosipatel_System add filegroup FG_2025
Alter database Hosipatel_System add filegroup FG_2026


Select *from Sys.filegroups 


----- Create data flies ---------------------

 Alter database Hosipatel_System Add file
 (
 Name = P_2023, --- logical name 
 FILENAME = ' '

 ----- Create function schema ---------------- 

 Create partition scheme paritionbyyearScheme 
 As partition Partitionbyyear to (FG_2023,FG_2024,FG_2025,FG_2026)

 ---------------Execution plan---------------

Select Distinct * from [dbo].[Patients] where PatientID='2' ---- it has to show sorting right 



---------------------- ERROR Handling ------------------- 

CREATE TABLE ErrorLog (
    ErrorID INT IDENTITY(1,1) PRIMARY KEY,
    ErrorDate DATETIME DEFAULT GETDATE(),
    ProcedureName VARCHAR(200),
    ErrorNumber INT,
    ErrorMessage VARCHAR(MAX),
    ErrorSeverity INT,
    ErrorState INT,
    UserName VARCHAR(100),
    AdditionalInfo VARCHAR(500)
)

---------------- Patient registeration with error handling ---------------- 

Create Procedure USP_Patientregisteration 
@Patientid Int, 
@Patientfirstname Varchar(100), 
@Patientlastname Varchar(100),
@Dateofbirth datetime, 
@Contactnumber Varchar(10), 
@gender Char(10),
@city varchar(100)
As
BEGIN 
 
Declare @errormessage varchar(max)
Declare @errornumber int
Declare @errorseverity int

Print 'Attempting to the register patinet' +@patientfirstname 
Print 'Attempting to the register patinet' +@patientlastname 
Print 'Patient id : '+ cast(@patientid as varchar(10))

Begin try 

BEGIN Transaction 

if exists (Select patientid from patients where Patientid =@Patientid)
 BEGIN
   RAISERROR('Patient ID %d already exists in the system. Cannot register duplicate.', 16, 1, @PatientID)
 END
 IF @PatientfirstName IS NULL OR LTRIM(RTRIM(@PatientfirstName)) = ''
        BEGIN
        RAISERROR('Patient name cannot be empty. Registration failed.', 16, 1)
  END
   IF @PatientlastName IS NULL OR LTRIM(RTRIM(@PatientlastName)) = ''
        BEGIN
        RAISERROR('Patient name cannot be empty. Registration failed.', 16, 1)
  END

  ---- if satify the above candtions please start inserting -------------- 

  insert into patients ( patientid, firstname,lastname,gender,dateofbirth,phone,city ) 
  Values 
  (
@Patientid ,
@Patientfirstname, 
@Patientlastname,
@gender,
@Dateofbirth, 
@Contactnumber ,
@city
) 

Commit Transaction 

Print ' Sucess : Patient registered successfully !' 

 END try 

BEGIN CATCH
        -- Rollback the transaction if it's active
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION
        
        -- Capture error details
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorMessage = ERROR_MESSAGE()
        SET @ErrorSeverity = ERROR_SEVERITY()
        
        -- Log the error to ErrorLog table
        INSERT INTO ErrorLog (ProcedureName, ErrorNumber, ErrorMessage, ErrorSeverity, ErrorState, UserName, AdditionalInfo)
        VALUES (
            'usp_RegisterNewPatient',
            @ErrorNumber,
            @ErrorMessage,
            @ErrorSeverity,
            ERROR_STATE(),
            SYSTEM_USER,
            'Failed to register PatientID: ' + CAST(@PatientID AS VARCHAR(10)) + ', Name: ' + ISNULL(@PatientfirstName, 'NULL')
        )
        
        -- Show friendly error message to user
       
        PRINT 'Error Number: ' + CAST(@ErrorNumber AS VARCHAR(10))
        PRINT 'Error Message: ' + @ErrorMessage
       

    END CATCH
END
GO

EXEC USP_Patientregisteration  
    @PatientID = 31,
    @PatientfirstName = 'Alice',
	@PatientlastName = 'Copper',
    @DateOfBirth = '1990-05-15',
    @ContactNumber = '555-0101',
	@gender ='M',
	@city ='Dallas'


SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
ORDER BY t.name;




SELECT * FROM Patients WHERE PatientID = 30

PRINT ''




        
























































