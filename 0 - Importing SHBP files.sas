*Importing RealAge data;

PROC IMPORT OUT= SHBP.SHBP_RealAge 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191008 - SHBP RealAge.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;


*Importing Lab 2014-2018 data;

PROC IMPORT OUT= SHBP.SHBP_Lab_14_18 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191008 - SHBP Lab 14-18.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*Importing WBA  data;

PROC IMPORT OUT= SHBP.WBA 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191008 - SHBP WBA.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;


*Importing Individual to GUID walkthrough from Jonas;

PROC IMPORT OUT= SHBP.IndividualID_GUID 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191008 - Guid_indiviualID.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;




*Alternitavly Importing WBA data with Guid;

PROC IMPORT OUT= SHBP.WBA_GUID 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191011 - SHBP WBA GUID.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;


* Importing SHBP eligibility file;

PROC IMPORT OUT= SHBP.SHBP_Eligibility 
            DATAFILE= "Y:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\20191011 - SHBP Eligibility.csv" 
            DBMS=DLM REPLACE;
     DELIMITER='09'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*Issue multiple record per memeber, therfore retain only max creata date;
proc sort data=SHBP.SHBP_eligibility;
by guid CreateDtUtc;
run;

Data SHBP.SHBP_eligibility_unique;
set SHBP.SHBP_eligibility;
by guid;
if last.guid;
run;


/*
*workaround for WBA Guid file - October 8th file was limited to memebrs with a Guid, but missing the Guid;

proc Sql;
create table shbp.WBA_Guid_workaround as
select b.datahub_id as Guid, a.*
from shbp.WBA a
left join shbp.individualid_guid b
on a.individual_id=b.individual_id;
quit;

*limit to rows where Guid is populated;

proc sql;
create table shbp.WBA_Guid_workaround_2 as
select * from shbp.WBA_Guid_workaround
where Guid is not null;
quit;

