CREATE TABLE Insurance_Providers (
    ProviderID INT PRIMARY KEY,
    ProviderName VARCHAR(100),
    ContactPhone VARCHAR(15),
    Email VARCHAR(100),
    CoverageType VARCHAR(50),
    PolicyTerms VARCHAR(100),
    Status VARCHAR(20)
);

CREATE TABLE Insurance_Claims (
    ClaimID INT PRIMARY KEY,
    BillID INT,
    PatientInsuranceID INT,
    ClaimDate DATE,
    ClaimAmount DECIMAL(10,2),
    ApprovedAmount DECIMAL(10,2),
    ClaimStatus VARCHAR(20),
    FOREIGN KEY (BillID) REFERENCES Bills(BillID),
    FOREIGN KEY (PatientInsuranceID) REFERENCES Patient_Insurance(PatientInsuranceID)
);


CREATE TABLE Insurance_Claims (
    ClaimID INT PRIMARY KEY,
    BillID INT,
    PatientInsuranceID INT,
    ClaimDate DATE,
    ClaimAmount DECIMAL(10,2),
    ApprovedAmount DECIMAL(10,2),
    ClaimStatus VARCHAR(20),
    FOREIGN KEY (BillID) REFERENCES Bills(BillID),
    FOREIGN KEY (PatientInsuranceID) REFERENCES Patient_Insurance(PatientInsuranceID)
);



INSERT INTO Insurance_Providers VALUES
(1,'Aetna','8001000001','support@aetna.com','Full','Standard','Active'),
(2,'BlueCross','8001000002','help@bcbs.com','Partial','Standard','Active'),
(3,'Cigna','8001000003','care@cigna.com','Full','Premium','Active'),
(4,'UnitedHealth','8001000004','info@uhc.com','Partial','Standard','Active'),
(5,'Humana','8001000005','support@humana.com','Full','Premium','Active'),
(6,'Kaiser','8001000006','help@kaiser.com','Partial','Basic','Active'),
(7,'MetLife','8001000007','care@metlife.com','Full','Standard','Active'),
(8,'WellCare','8001000008','info@wellcare.com','Partial','Basic','Active'),
(9,'Oscar','8001000009','support@oscar.com','Full','Premium','Active'),
(10,'Anthem','8001000010','help@anthem.com','Full','Standard','Active'),
(11,'CareFirst','8001000011','info@carefirst.com','Partial','Standard','Active'),
(12,'Molina','8001000012','support@molina.com','Basic','Basic','Active'),
(13,'HealthNet','8001000013','help@healthnet.com','Partial','Standard','Active'),
(14,'Centene','8001000014','info@centene.com','Basic','Basic','Active'),
(15,'AvMed','8001000015','support@avmed.com','Full','Premium','Active'),
(16,'Caresource','8001000016','help@caresource.com','Basic','Standard','Active'),
(17,'Highmark','8001000017','info@highmark.com','Partial','Standard','Active'),
(18,'EmblemHealth','8001000018','support@emblem.com','Full','Standard','Active'),
(19,'Tricare','8001000019','help@tricare.com','Full','Government','Active'),
(20,'Medicaid','8001000020','support@medicaid.gov','Basic','Government','Active'),
(21,'Medicare','8001000021','help@medicare.gov','Basic','Government','Active'),
(22,'Oxford','8001000022','info@oxford.com','Partial','Standard','Active'),
(23,'BrightHealth','8001000023','support@bright.com','Full','Premium','Active'),
(24,'FridayHealth','8001000024','help@friday.com','Partial','Basic','Active'),
(25,'Clover','8001000025','info@clover.com','Basic','Government','Active'),
(26,'FirstHealth','8001000026','support@firsthealth.com','Full','Standard','Active'),
(27,'HealthPartners','8001000027','help@hp.com','Partial','Standard','Active'),
(28,'CarePlus','8001000028','info@careplus.com','Basic','Basic','Active'),
(29,'Aspirus','8001000029','support@aspirus.com','Partial','Standard','Active'),
(30,'IndependentHealth','8001000030','help@indhealth.com','Full','Premium','Active');



INSERT INTO Patient_Insurance VALUES
(1,1,1,'POL1001','2022-01-01','2025-01-01',80),
(2,2,2,'POL1002','2022-02-01','2025-02-01',70),
(3,3,3,'POL1003','2022-03-01','2025-03-01',90),
(4,4,4,'POL1004','2022-04-01','2025-04-01',75),
(5,5,5,'POL1005','2022-05-01','2025-05-01',85),
(6,6,6,'POL1006','2022-06-01','2025-06-01',65),
(7,7,7,'POL1007','2022-07-01','2025-07-01',80),
(8,8,8,'POL1008','2022-08-01','2025-08-01',60),
(9,9,9,'POL1009','2022-09-01','2025-09-01',90),
(10,10,10,'POL1010','2022-10-01','2025-10-01',85),
(11,11,11,'POL1011','2022-11-01','2025-11-01',70),
(12,12,12,'POL1012','2022-12-01','2025-12-01',60),
(13,13,13,'POL1013','2023-01-01','2026-01-01',75),
(14,14,14,'POL1014','2023-02-01','2026-02-01',65),
(15,15,15,'POL1015','2023-03-01','2026-03-01',90),
(16,16,16,'POL1016','2023-04-01','2026-04-01',70),
(17,17,17,'POL1017','2023-05-01','2026-05-01',80),
(18,18,18,'POL1018','2023-06-01','2026-06-01',85),
(19,19,19,'POL1019','2023-07-01','2026-07-01',95),
(20,20,20,'POL1020','2023-08-01','2026-08-01',100),
(21,21,21,'POL1021','2023-09-01','2026-09-01',100),
(22,22,22,'POL1022','2023-10-01','2026-10-01',75),
(23,23,23,'POL1023','2023-11-01','2026-11-01',85),
(24,24,24,'POL1024','2023-12-01','2026-12-01',65),
(25,25,25,'POL1025','2024-01-01','2027-01-01',100),
(26,26,26,'POL1026','2024-02-01','2027-02-01',80),
(27,27,27,'POL1027','2024-03-01','2027-03-01',75),
(28,28,28,'POL1028','2024-04-01','2027-04-01',60),
(29,29,29,'POL1029','2024-05-01','2027-05-01',70),
(30,30,30,'POL1030','2024-06-01','2027-06-01',90);


INSERT INTO Insurance_Claims VALUES
(1,1,1,'2023-01-15',500,400,'Approved'),
(2,2,2,'2023-01-16',600,420,'Approved'),
(3,3,3,'2023-01-17',700,630,'Approved'),
(4,4,4,'2023-01-18',800,600,'Approved'),
(5,5,5,'2023-01-19',550,468,'Approved'),
(6,6,6,'2023-01-20',450,292,'Approved'),
(7,7,7,'2023-01-21',650,520,'Approved'),
(8,8,8,'2023-01-22',400,240,'Approved'),
(9,9,9,'2023-01-23',900,810,'Approved'),
(10,10,10,'2023-01-24',750,637,'Approved'),
(11,11,11,'2023-01-25',500,350,'Approved'),
(12,12,12,'2023-01-26',300,180,'Approved'),
(13,13,13,'2023-01-27',600,450,'Approved'),
(14,14,14,'2023-01-28',550,357,'Approved'),
(15,15,15,'2023-01-29',800,720,'Approved'),
(16,16,16,'2023-01-30',700,490,'Approved'),
(17,17,17,'2023-02-01',650,520,'Approved'),
(18,18,18,'2023-02-02',900,765,'Approved'),
(19,19,19,'2023-02-03',1000,950,'Approved'),
(20,20,20,'2023-02-04',1200,1200,'Approved'),
(21,21,21,'2023-02-05',1100,1100,'Approved'),
(22,22,22,'2023-02-06',750,562,'Approved'),
(23,23,23,'2023-02-07',850,722,'Approved'),
(24,24,24,'2023-02-08',400,260,'Approved'),
(25,25,25,'2023-02-09',1300,1300,'Approved'),
(26,26,26,'2023-02-10',900,720,'Approved'),
(27,27,27,'2023-02-11',700,525,'Approved'),
(28,28,28,'2023-02-12',500,300,'Approved'),
(29,29,29,'2023-02-13',650,455,'Approved'),
(30,30,30,'2023-02-14',800,720,'Approved');



Select Top 1* from [dbo].[Insurance_Claims]










----------- Dynamic SQL Scenario ---------------------- 

CREATE PROCEDURE GetDynamicAppointments
    @DoctorID INT = NULL,
    @Status NVARCHAR(50) = NULL,
	@PatientfirstName NVARCHAR(100) = NULL,
    @PatientLastName NVARCHAR(100) = NULL
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    -- Base query joining Patients and Appointments
    SET @SQL = N'SELECT A.AppointmentID, A.AppointmentDate, A.Status, 
                       P.FirstName, P.LastName, D.DoctorName
                FROM Appointments A
                JOIN Patients P ON A.PatientID = P.PatientID
                JOIN Doctors D ON A.DoctorID = D.DoctorID
                WHERE 1=1';

    -- Build conditions based on provided parameters
    IF @DoctorID IS NOT NULL
        SET @SQL += N' AND A.DoctorID = @pDocID';
    
    IF @Status IS NOT NULL
        SET @SQL += N' AND A.Status = @pStatus';

    IF @PatientLastName IS NOT NULL
        SET @SQL += N' AND P.LastName LIKE @pName';

    EXEC sp_executesql @SQL,
        N'@pDocID INT, @pStatus NVARCHAR(50), @pName NVARCHAR(100)',
        @pDocID = @DoctorID, @pStatus = @Status, @pName = @PatientLastName + '%';
END














