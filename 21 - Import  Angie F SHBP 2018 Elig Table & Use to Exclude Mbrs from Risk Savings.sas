
*IMPORT NEW 2018 SHBP ELIG TABLE, AND USE TO EXCLUDE ALL MEMBERS FROM THE INDIVIDUAL RISK BEHAVIOR CHANGE SAVINGS, WHO DONT HAVE AT LEAST
1 OR MORE MONTHS OF ELIGIBILITY IN THE 2018 YEAR;

********************************************************************************************************************;
********************************************************************************************************************;
********************************************************************************************************************;

*ANGIE FREEMAN SHARED A NEW 2018 SHBP ELIGIBILITY FILE, I IMPORTED - 'Shbp_elig_2018_angie';
PROC IMPORT OUT= WORK.SHBP_elig_angie 
            DATAFILE= "O:\2019 RADS\SHBP Outcomes\3. Pulling Data\2. Dat
a\shbp_2018_elig.txt" 
            DBMS=DLM REPLACE;
     DELIMITER='7C'x; 
     GETNAMES=YES;
     DATAROW=2; 
RUN;


proc freq data=Shbp_elig_2018_angie;
table ORG_UNIT_NAME MONTHS_ELIGIBLE;
title 'Looking at New SHBP 2018 Eligibility Table - from Angie';
run;

*ADD A NEEDED 'GUID' CHARACTER VARIABLE;
proc sql;
create table Shbp_elig_2018_angie2 as
select strip(put(Guid, 15.)) as Guid_char, Guid, max(a.MONTHS_ELIGIBLE) as months_eligible, OrgUnitID, Org_Unit_name,
       datepart(Real_Age_Completion) as Real_Age_Completion_Date format=mmddyy10.
from Shbp_elig_2018_angie a
group by Guid_char, Guid, OrgUnitID, Org_Unit_name, Real_Age_Completion_Date
;
quit;

proc freq data=Shbp_elig_2018_angie2;
table OrgUnitID*Org_Unit_name;
run;

* ANGIE COMMUNICATED THAT SHE USES JUST THESE ORG_UNIT_IDs IN BILLING: 111243362 and 111243372 ;


********************************************************************************************************************;
********************************************************************************************************************;


*ALCOHOL;
Data Alc_working_risk3_update;
set Alc_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Alc_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
quit;

*1178,261 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Alc_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;


*ALCOHOL - RESULT IS THE SAME;
proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Alc_Impact_Savings2) as alcohol_savings format=dollar15.2
from Alc_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Alc_Impact_Savings2) as alcohol_savings format=dollar15.2
from Alc_working_risk3_update
where elig_months_2018 ge 1
;
quit;


Data Alc_working_risk3_update2;
set Alc_working_risk3_update;

if elig_months_2018 ge 1;
run;

*JUST A CHECK TO MAKE SURE PROPER RECORDS BEING USED AND TOTAL SUM DOLLARS AGREE WITH QUERY ABOVE;
proc means sum data=Alc_working_risk3_update2;
var Alc_Impact_Savings Alc_Impact_Savings2 impact1 drinks_T1 drinks_T2;
title 'Final Result for SHBP Alcohol Use Analysis';
run;

**************************************************************;
**************************************************************;


*PHYSICAL ACTIVITY;

Data Activity_working_risk3_update;
set Activity_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Activity_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
quit;


*117,123 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Activity_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*PHYSICAL ACTIVITY - RESULT IS THE SAME;
proc sql;
title 'SHBP Physical Activity Risk Change Savings Result';
select sum(Activity_Impact_Savings2) as activity_savings format=dollar15.2
from Activity_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'SHBP Physical Activity Risk Change Savings Result';
select sum(Activity_Impact_Savings2) as activity_savings format=dollar15.2
from Activity_working_risk3_update
where elig_months_2018 ge 1
;
quit;

**************************************************************;
**************************************************************;


*ILLNESS DAYS;

Data Illness_working_risk3_update;
set Illness_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Illness_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
quit;


*117,135 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Illness_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*ILLNESS DAYS - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP ILLNESS DAYS Analysis';
select sum(ILLNESS_Impact_Savings2) as illness_savings format=dollar15.2
from Illness_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP ILLNESS DAYS Analysis';
select sum(ILLNESS_Impact_Savings2) as illness_savings format=dollar15.2
from Illness_working_risk3_update
where elig_months_2018 ge 1
;
quit;

**************************************************************;
**************************************************************;


*STRESS;

Data Stress_working_risk3_update;
set Stress_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Stress_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
quit;


*112,211 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Stress_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*STRESS - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP STRESS Analysis';
select sum(STRESS_Impact_Savings2) as stress_savings format=dollar15.2
from Stress_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP STRESS Analysis';
select sum(STRESS_Impact_Savings2) as stress_savings format=dollar15.2
from Stress_working_risk3_update
where elig_months_2018 ge 1
;
quit;


Data Stress_working_risk3_update2;
set Stress_working_risk3_update;

if elig_months_2018 ge 1;
run;

*JUST A CHECK TO MAKE SURE PROPER RECORDS BEING USED AND TOTAL SUM DOLLARS AGREE WITH QUERY ABOVE;
proc means sum data=Stress_working_risk3_update2;
var STRESS_Impact_Savings STRESS_Impact_Savings2;
title 'Final Result for SHBP Stress Analysis';
run;


**************************************************************;
**************************************************************;

*MEDICATION FOR RELAXATION;

Data Meds_working_risk3_update;
set Meds_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Meds_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
quit;


*119,113 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Meds_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*MEDS FOR RELAXATION - RESULT IS THE SAME;
proc sql;
title ' Final Result for SHBP MEDS_FOR_RELAXATION Analysis';
select sum(MEDS_Impact_Savings2) as MEDS_savings format=dollar15.2
from Meds_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title ' Final Result for SHBP MEDS_FOR_RELAXATION Analysis';
select sum(MEDS_Impact_Savings2) as MEDS_savings format=dollar15.2
from Meds_working_risk3_update
where elig_months_2018 ge 1
;
quit;

*119,113 RECORDS;
Data Meds_working_risk3_update2;
set Meds_working_risk3_update;

if elig_months_2018 ge 1;
run;

*JUST A CHECK TO MAKE SURE PROPER RECORDS BEING USED AND TOTAL SUM DOLLARS AGREE WITH QUERY ABOVE;
proc means sum data=Meds_working_risk3_update2;
var MEDS_Impact_Savings MEDS_Impact_Savings2;
title ' Final Result for SHBP MEDS_FOR_RELAXATION Analysis';
run;



**************************************************************;
**************************************************************;

*BLOOD PRESSURE;

Data Bp_working_risk3_update;
set Bp_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Bp_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*87,645 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Bp_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*BLOOD PRESSURE - RESULT IS THE SAME;
proc sql;
title ' Final Result for SHBP BP Analysis';
select sum(BP_Impact_Savings2) as BP_savings format=dollar15.2
from Bp_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title ' Final Result for SHBP BP Analysis';
select sum(BP_Impact_Savings2) as BP_savings format=dollar15.2
from Bp_working_risk3_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*BODY MASS INDEX;

Data Bmi_working_risk3_update;
set Bmi_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Bmi_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*87,864 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Bmi_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*BMI - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP BMI Analysis';
select sum(BMI_Impact_Savings2) as BMI_savings format=dollar15.2
from Bmi_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP BMI Analysis';
select sum(BMI_Impact_Savings2) as BMI_savings format=dollar15.2
from Bmi_working_risk3_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*LIFE SATISFACTION;

Data Life_working_risk3_dq_update;
set Life_working_risk3_dq;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Life_working_risk3_dq_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*117,828 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Life_working_risk3_dq_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*LIFE SATISFACTION - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP LIFE SATISFACTION Analysis';
select sum(LIFE_Impact_Savings2) as LIFE_savings format=dollar15.2
from Life_working_risk3_dq_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP LIFE SATISFACTION Analysis';
select sum(LIFE_Impact_Savings2) as LIFE_savings format=dollar15.2
from Life_working_risk3_dq_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*SMOKING;

Data Smoke_working_risk3_update;
set Smoke_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Smoke_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*118,460 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Smoke_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*SMOKING - RESULT IS THE SAME;
proc sql;
title ' Final Result for SHBP SMOKING Analysis';
select sum(SMOKE_Impact_Savings2) as SMOKE_savings format=dollar15.2
from Smoke_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title ' Final Result for SHBP SMOKING Analysis';
select sum(SMOKE_Impact_Savings2) as SMOKE_savings format=dollar15.2
from Smoke_working_risk3_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*OVERALL PERCEPTION OF HEALTH;

Data Percept_working_risk3_update;
set Percept_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Percept_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*117,879 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Percept_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid_char
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid_char
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*PERCEPTION OF HEALTH - RESULT IS THE SAME;
proc sql;
title ' Final Result for SHBP PERCEPTION OF HEALTH RISK Analysis';
select sum(PERCEPT_Impact_Savings2) as PERCEPT_savings format=dollar15.2
from Percept_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title ' Final Result for SHBP PERCEPTION OF HEALTH RISK Analysis';
select sum(PERCEPT_Impact_Savings2) as PERCEPT_savings format=dollar15.2
from Percept_working_risk3_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*HDL;

Data Hdl_working_risk3_update;
set Hdl_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Hdl_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*87,123 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Hdl_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*HDL - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP HDL CHOLESTEROL Analysis';
select sum(HDL_Impact_Savings2) as HDL_savings format=dollar15.2
from Hdl_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP HDL CHOLESTEROL Analysis';
select sum(HDL_Impact_Savings2) as HDL_savings format=dollar15.2
from Hdl_working_risk3_update
where elig_months_2018 ge 1
;
quit;


**************************************************************;
**************************************************************;

*TOTAL CHOLESTEROL;

Data Totalchol_working_risk3_update;
set Totalchol_working_risk3;

elig_months_2018 = 0;
run;


proc sql;
create index Guid on Totalchol_working_risk3_update(Guid);
create index Guid_char on Shbp_elig_2018_angie2(Guid_char);
create index Guid on Shbp_elig_2018_angie2(Guid);
quit;


*87,541 RECORDS WERE UPDATED WITH A COUNT OF 2018 ELIG MONTHS;
proc sql;
update Totalchol_working_risk3_update a
set elig_months_2018 = (select max(months_eligible)
                        from Shbp_elig_2018_angie2 b
						where a.Guid = b.Guid
                        and b.OrgUnitID in (111243362,111243372))
where exists (select 'x' 
              from Shbp_elig_2018_angie2 b
			  where a.Guid = b.Guid
              and b.OrgUnitID in (111243362,111243372))
; 
quit;

*TOTAL CHOLESTEROL - RESULT IS THE SAME;
proc sql;
title 'Final Result for SHBP TOTAL CHOLESTEROL Analysis';
select sum(TOTALCHOL_Impact_Savings2) as TOTCHOL_savings format=dollar15.2
from Totalchol_working_risk3_update
;
quit;


*NEW RESULT - TAKING TO ACCOUNT THAT MEMBER SHOWS ELIG MONTHS IN 2018 YEAR;
proc sql;
title 'Final Result for SHBP TOTAL CHOLESTEROL Analysis';
select sum(TOTALCHOL_Impact_Savings2) as TOTCHOL_savings format=dollar15.2
from Totalchol_working_risk3_update
where elig_months_2018 ge 1
;
quit;



*GET COUNTS OF MEMBERS WHO HAVE FALLEN OUT;
proc freq data=Totalchol_working_risk3_update;
table elig_months_2018;
title 'totalchol 2018 elig months';
run;


proc freq data=Smoke_working_risk3_update;
table elig_months_2018;
title 'Smoke 2018 elig months';
run;



proc freq data=Stress_working_risk3_update;
table elig_months_2018;
title 'Stress 2018 elig months';
run;



proc freq data=Meds_working_risk3_update;
table elig_months_2018;
title 'Meds 2018 elig months';
run;












