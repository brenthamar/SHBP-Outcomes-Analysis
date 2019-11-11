*BLOOD PRESSURE RISK MEASURE;

*714,884 RECORDS PULLED - SYSTOLIC OR DIASTOLIC BP;
proc sql;
create table SHBP_BP_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'BPDIA'
or TestName = 'BPSYS'
order by calculated DOS
;
quit;

****************************************************************;
*GET FIRST AND LAST SYSTOLIC BP READINGS;
Data systolic1;
set SHBP_BP_records;

if TestName = 'BPSYS';

proc sort data=systolic1;
by GUID DOS;
run;

*154,511 RECORDS;
Data systolic_first;
set systolic1;
by guid;
if first.guid;
run;

*154,511 RECORDS;
Data systolic_last;
set systolic1;
by guid;
if last.guid;
run;

*98,405 RECORDS;
proc sql;
create table SYSTOLIC_first_last as
select 	a.guid, 
		a.TestName,
		a.DOS as Date_First,
		a.Year as Year_First,
		input(a.TestResultValue, 5.) as Sys_First,
		0 as Risk_First,
		b.DOS as Date_Last,
		b.Year as Year_Last,
		input(b.TestResultValue, 5.) as Sys_Last,
		0 as Risk_Last
from systolic_first a inner join systolic_last b
on a.guid = b.guid
where a.DOS <> b.DOS;
quit;


*****************************************************************;
*GET FIRST AND LAST DIASTOLIC BP READINGS;

Data diastolic1;
set SHBP_BP_records;

if TestName = 'BPDIA';

proc sort data=diastolic1;
by GUID DOS;
run;

*154,504 RECORDS;
Data diastolic_first;
set diastolic1;
by guid;
if first.guid;
run;

*154,504 RECORDS;
Data diastolic_last;
set diastolic1;
by guid;
if last.guid;
run;

*98,415 RECORDS;
proc sql;
create table DIASTOLIC_first_last as
select 	a.guid, a.guid*1 as Guid_num,
		a.TestName,
		a.DOS as Date_First,
		a.Year as Year_First,
		input(a.TestResultValue, 5.)as Dias_First,
		0 as Risk_First,
		b.DOS as Date_Last,
		b.Year as Year_Last,
		input(b.TestResultValue, 5.) as Dias_Last,
		0 as Risk_Last
from diastolic_first a inner join diastolic_last b
on a.guid = b.guid
where a.DOS <> b.DOS;
quit;

*****************************************************************;
*BRING SYSTOLIC AND DIASTOLIC READINGS TOGETHER;

*97,761 RECORDS;
proc sql;
create table bp_summary1 as
select a.Guid, a.date_first, a.Year_first, a.Sys_first, b.Dias_first, a.Risk_First,
               a.date_last, a.Year_last, a.Sys_last, b.Dias_last, a.Risk_Last  
from SYSTOLIC_first_last a, DIASTOLIC_first_last b
where a.Guid = b.Guid
and a.Date_First = b.Date_First
and a.Date_Last = b.Date_Last
and a.year_first <> a.year_last
;
quit;


proc sql;
select count(distinct guid) as member_count
from bp_summary1
;
quit;

*RECORDS ARE FROM 2014 TO 2018, SO NO RECORDS IN 2019 THAT HAVE TO BE DELETED;
proc freq data=bp_summary1;
table Year_first Year_last;
run;

*****************************************************************;

*BRING IN DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

*TABLE WITH *97,274 RECORDS;
Proc sql;
create table BP_First_Last_Final as
select a.Guid, b.DOB, 
       input( b.DOB, anydtdte24.) as DOB2 format=mmddyy10.,       
       floor((a.Date_Last - calculated DOB2)/365.25) as Age format=3., 
       b.gender,
  case
  when b.gender = '02' then 'Male'
  when b.gender = '03' then 'Female'
  else 'Unknown'
  end as Gender2,
  case
  when calculated Age between 18 and 34 then 'age 18-34'
  when calculated Age between 35 and 44 then 'age 35-44' 
  when calculated Age between 45 and 54 then 'age 45-54' 
  when calculated Age between 55 and 64 then 'age 55-64' 
  when calculated Age ge 65 then 'age 65+'
  end as AgeGroup, a.*
from bp_summary1 a inner join shbp2.shbp_eligibility_unique b
on a.Guid = b.Guid;
quit;


*****************************************************************;
*SET RISK FLAGS, BASED ON FIRST AND LAST SYSTOLIC/DIASTOLIC READINGS;

Data BP_working_risk1; 
set BP_First_Last_Final;

if sys_first > 139 then Risk_First = 1;
if dias_first > 89 then Risk_First = 1;


if sys_last > 139 then Risk_Last = 1;
if dias_last > 89 then Risk_Last = 1;
run;



proc freq data=BP_working_risk1;
table Risk_First Risk_Last;
title 'Comparison of BP Risk Flags from First and Last Reading';
run;


*****************************************************************;


*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO ELIMINATE BP RISK;

Data BP_working_risk2; /*(keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact1 Risk_Last_Updated);*/ 
set BP_working_risk1;

BP_Value_per_Risk = 221.0;

Impact1 = 0;

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE ACTIVITY RISK;
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP ACTIVITY RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;

format BP_Value_per_Risk DOLLAR10.2;
format Impact1 6.3;

run;

*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN BP RISK;

Data BP_working_risk3;
set BP_working_risk2;


BP_Impact_Savings = Impact1*BP_Value_per_Risk;

format BP_Impact_Savings DOLLAR10.2;
run;


*****************************************************************;

*FINANCIAL RESULTS ASSOCATIED WITH CHANGE IN BP;

proc freq data=BP_working_risk3;
table BP_Impact_Savings;
title 'SHBP - Frequency of BP Impact'; 
run;

proc means sum data=BP_working_risk3;
var BP_Impact_Savings;
title ' Final Result for SHBP BP Analysis';
run;


proc sort data=BP_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP BP Savings by Last Year Shown on Record';
select year_last, count(*) as rec_count, sum(BP_Impact_Savings) as savings_amount format=DOLLAR10.2
from BP_working_risk3
group by year_last
;
quit;


proc sql;
title 'Sum of SHBP BP Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(BP_Impact_Savings) as savings_amount format=DOLLAR10.2
from BP_working_risk3
group by year_first, year_last
;
quit;





















*NOT USING THIS CODE BELOW;

Data bp_summary2;
set bp_summary1;
run;


proc sql;
create index guid on bp_summary1(guid);
create index guid on bp_summary2(guid);
quit;


proc sql;
update bp_summary2 a
set Risk_First = 1
where a.Guid in (select b.guid 
                 from bp_summary1 b
			     where a.guid = b.guid
			     and (b.sys_first > 139 or b.dias_first > 89))
;
run;
quit;



proc freq data=bp_summary2;
table Risk_First;
run;


Data bp_summary3;
set bp_summary1;

if sys_first > 139 then Risk_First = 1;
if dias_first > 89 then Risk_First = 1;


if sys_last > 139 then Risk_Last = 1;
if dias_last > 89 then Risk_Last = 1;

run;


proc freq data=bp_summary3;
table Risk_First Risk_Last;
title 'Check on the First and Last Risk Flag';
run;
