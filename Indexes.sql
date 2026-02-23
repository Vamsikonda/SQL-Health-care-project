------- Column Store ----------------------

select FinanceKey,DateKey,Organizationkey,departmentgroupkey,scenariokey,accountkey,amount,[date]
into CI_FACTFIN
from adventureworksdw2016.dbo.factfinance

select FinanceKey,DateKey,Organizationkey,departmentgroupkey,scenariokey,accountkey,amount,[date]
into CSI_FACTFIN
from adventureworksdw2016.dbo.factfinance

select * from CI_FACTFIN

select * from CSI_FACTFIN

create clustered index ci_ci_factfin_datekey on ci_factfin(financekey,datekey)
create columnstore index csi_ci_factfin_finkey_datekey on csi_factfin(FinanceKey,DateKey,Organizationkey,departmentgroupkey)

select FinanceKey,DateKey,Organizationkey,departmentgroupkey
from CI_FACTFIN
---- Estimated IO Cost -------- 0.18 
----- Estimated CPU Cost ----------0.043

select FinanceKey,DateKey,Organizationkey,departmentgroupkey
from CSI_FACTFIN  

---- Estimated IO Cost --------0.01
----- Estimated CPU Cost ----------0.043

---------------- Indexes ----------------------- 


Select *into Patientstable 
from Patients

SP_helpindex 'Patientstable'

------ CLsuterd index --------------- TBSCAN to CISeek and TBS to CISCAN

Create clustered index IX_Clu_PID on Patientstable (patientid) 

Select *from Patientstable where patientid=10 ---------Clustered index seek 

Select firstname,lastname from Patientstable where patientid=10 --------- CISeek

Select patientID from Patientstable where LastName='Thomas' ------ CISCAN 

Select *from patientstable where FirstName ='Olivia'  -------- CISCAN  


---------------- Non Clustered index on Clustered index --------------- 

Create Nonclustered index IX_NONCI_NAme on Patientstable (firstname) 


Select *from Patientstable  ------CISCAN 

Select  patientID,Firstname from Patientstable where firstname ='Olivia' ---- NONCISEEK
Select patientID from patientstable where Firstname ='Olivia' ---- NONCISEEK
Select firstname,lastname,city from patientstable where patientid =12  --- CISEEK

Select firstname,lastname,city from patientstable where Firstname ='Olivia' and patientid =12 --- CISEEK 
Select patientid from  patientstable where FIRSTname ='Olivia' and lastname ='Thomas' -------- Wrong it should NON CLUSTERED INDEX WITH RID lookup --------

SELECT FirstName, City
FROM PatientsTable
WHERE FirstName = 'Olivia';


---------------- non Clustered index on heap ------------

Drop index IX_NONCI_NAme on patientstable
Drop index IX_Clu_PID on patientstable
Drop index IX_NONCI_NAme2 on patientstable
Drop index IX_NONCI_NAme3 on patientstable

SP_helpindex 'patientstable'

Create Nonclustered index IX_NONCI_NAme on Patientstable (firstname) 

Select  firstname from Patientstable where firstname ='olivia' ----- Table scan 
Select  firstname from Patientstable where firstname ='olivia'  ---- After creating also it should show NONCIseek with RID lookup , But is not showing --




Select * from Patientstable where firstname ='olivia'  ----it should show NCISEEK but it says TSCAN ----

Create Nonclustered index IX_NONCI_NAme1 on Patientstable (lastname,patientID) 

Select lastname,firstname,patientid from Patientstable where City = 'Dallas'  ----- Table scan its correct 

Select *from Patientstable where firstname ='olivia' or lastname ='thomas' or patientid =1 --- it shows tab le scan 

Create Nonclustered index IX_NONCI_NAme2 on Patientstable (lastname,patientID) include(City)

Create Nonclustered index IX_NONCI_NAme3 on Patientstable (lastname,patientID) where City ='Dallas'














