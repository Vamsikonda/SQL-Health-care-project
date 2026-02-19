--- User Define function ------------- 


CREATE FUNCTION dbo.CalculateAge
(@BirthDate DATE) RETURNS INT AS 
BEGIN 
RETURN 
DATEDIFF(YEAR, @BirthDate, GETDATE()) 
END  

Select top 1* from [dbo].[Patients]

Select patientid,firstname,lastname,dbo.CalculateAge(Dateofbirth) as age from patients

----- Business Need: Blood bank needs to quickly verify donor-recipient compatibility during emergencies 

Create or alter function DBO.compatbility 
(@donar varchar(100), @receipt varchar(100)) Returns Varchar(100) 
AS 
BEGIN 
 Declare @result varchar(100)
 if (@donar ='o-') 
 SET @result ='Matching' 
 ELSE if (@donar = @receipt) 
 Set @result = 'Matching' 
 ELSE if(@receipt ='AB+')
  SET @Result = 'Matching'
  ELSE 
  SET @result ='Not matching' 

  REturn @result 
END 

------------- inline valued functions -------------- 

Create function fn_doctoravaliblity 
(@doctorid int, @date datetime ) 
Returns Table 
AS 
RETURN 
(
    SELECT 
        ds.Shiftid,
        ds.StartTime,
        ds.EndTime,
        d.DoctorName,
        d.Specialization,
        CASE 
            WHEN a.AppointmentID IS NULL THEN 'Available'
            ELSE 'Booked'
        END AS Status
    FROM Doctor_Shifts ds
    INNER JOIN Doctors d ON ds.DoctorID = d.DoctorID
    LEFT JOIN Appointments a ON ds.DoctorID = a.DoctorID 
                              AND a.AppointmentDate = @Date
    WHERE ds.DoctorID = @doctorid
        AND ds.Status = 'Active'
)

SELECT * FROM fn_doctoravaliblity(101, getdate())
WHERE Status = 'Active'




------------------ Triggers -----------------

-- Create audit history table
CREATE TABLE AppointmentHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT,
    patientid Int,
    Doctorid INt,
    AppointmentDate DATETIME,
	Action varchar(20),
    Department VARCHAR(50),
	Medication varchar(10),
	Actiondate date
 
)

Select *from AppointmentHistory
Alter table AppointmentHistory
Add Actiondate date
-- Create simple AFTER INSERT trigger

CREATE or alter TRIGGER tr_LogNewAppointment
ON Appointments
AFTER INSERT
AS
BEGIN
    -- Automatically log the new appointment
    INSERT INTO AppointmentHistory (
         AppointmentID,
        Patientid,
        doctorid,
        AppointmentDate,
        Action,
		Department,
		medication,
		Typeofaction,
		Actionby,
		Actiondate

    )
    SELECT 
        AppointmentID,
        Patientid,
        doctorid,
        AppointmentDate,
        Status,
		reason,
		medication,
		'NEW APPOINTMENT CREATED',
        SYSTEM_USER,
		GETDATE()
		FROM INSERTED
    
    PRINT  'Appointment saved and logged in history'
END

-- TEST: Add some appointments
INSERT INTO Appointments VALUES 
(131,1, 101, '2024-02-20 ', 'Pending', 'Cardiology','Atenolol')

INSERT INTO Appointments VALUES 
(133,3, 102, '2024-02-21 ', 'Schuled', 'Fracture','Atenolol')

INSERT INTO Appointments VALUES 
(134,4, 103, '2024-02-20', 'Schuled', 'Fever','Atenolol')

INSERT INTO Appointments VALUES 
(136,4, 103, '2024-02-20', 'Schuled', 'Fever','Atenolol')

INSERT INTO Appointments VALUES 
(135,4, 104, '2024-02-20', 'pending', 'Fever','Atenolol')
-- View appointments
SELECT * FROM Appointments

-- View the automatic history log
SELECT *
FROM AppointmentHistory
ORDER BY ActionDate DESC

-- Add more appointments
INSERT INTO Appointments VALUES 
(104, 'Jennifer Martinez', 'Dr. David Rodriguez', '2024-02-22 11:00', 'Pediatrics', 'Scheduled'),
(105, 'William Brown', 'Dr. Michael Chen', '2024-02-22 15:00', 'Orthopedics', 'Scheduled')

-- Check history again - new entries automatically added
SELECT * FROM AppointmentHistory