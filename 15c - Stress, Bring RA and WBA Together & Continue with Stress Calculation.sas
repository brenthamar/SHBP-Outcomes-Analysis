

*BRING REALAGE AND WBA RECORDS TOGETHER,  THESE TABLES COME FROM a AND b PROGRAMS;

proc sql;
create table Stress_RA_WBA_merged as
select distinct 'RA ' as Record_Type, guid, from_date as date format=mmddyy10., year, 
       Marital_Status, Personal_Loss, Life_Sat, Percept_Health, Sleep_Hrs, Social,
       Marital_Status2, Personal_Loss2, Life_Sat2, Percept_Health2, Sleep_Hrs2, Social2,
	   stress_composite_score
from stress_RA_quest3
UNION
select distinct 'WBA' as Record_Type, guid, response_date2 as date format=mmddyy10., year, 
       Marital_Status, Personal_Loss, Life_Sat, Percept_Health, Sleep_Hrs, Social,
       Marital_Status2, Personal_Loss2, Life_Sat2, Percept_Health2, Sleep_Hrs2, Social2,
	   stress_composite_score
from stress_wba_quest3
;
quit;



*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=Stress_RA_WBA_merged;
by guid date;
run;


*STRESS First value;
*N=213,271 RECORDS;
Data STRESS_first;
set Stress_RA_WBA_merged;
by guid;
if first.guid;
run;

*STRESS Last value;
*N=213,271 RECORDS;
Data STRESS_last;
set Stress_RA_WBA_merged;
by guid;
if last.guid;
run;



*JOIN BOTH FIRST AND PERCEPT RECORD FILES;
*139,150 RECORDS IN TABLE;
proc sql;
create table STRESS_first_last as
select 	a.guid, 
		'Stress' as item,
		a.Record_Type as Record_First,
		a.date as Date_First,
		a.Year as Year_First,
		a.stress_composite_score as stress_composite_First,
		0 as Risk_First,
		b.Record_Type as Record_Last,
		b.date as Date_Last,
		b.Year as Year_Last,
		b.stress_composite_score as stress_composite_Last,
		0 as Risk_Last
from STRESS_first a inner join STRESS_last b
on a.guid = b.guid
where a.date <> b.date;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*139,150 RECORDS TO 138,985 RECORDS;
Data STRESS_first_last;
set STRESS_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;
*****************************************************************;

Data STRESS_first_last2;
set STRESS_first_last;
Guid_num = guid*1;
run;

*TABLE WITH 138,955 RECORDS PRODUCED;
Proc sql;
create table STRESS_First_Last_Final as
select distinct a.Guid, a.Guid_num, b.DOB, 
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
  end as AgeGroup,
  case
  when year_last - year_first = 5 then 'Year 5'
  when year_last - year_first = 4 then 'Year 4'
  when year_last - year_first = 3 then 'Year 3'
  when year_last - year_first = 2 then 'Year 2'
  when year_last - year_first = 1 then 'Year 1'
  else 'unknown'
  end as year_in_pgm,    
  case
  when stress_composite_Last lt stress_composite_First then 'decreased'
  when stress_composite_Last gt stress_composite_First then 'increased' 
  when stress_composite_Last = stress_composite_First then 'no change'
  else 'unknown'
  end as change_in_STRESS, a.*
from STRESS_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data=STRESS_First_Last_Final;
table gender Gender2 change_in_STRESS;
run;

proc means mean data=STRESS_First_Last_Final;
var stress_composite_First stress_composite_Last;
run;


*****************************************************************;

*DISCARD RECORDS THAT HAVE A MISSING 'STRESS_COMPOSITE_RISK_SCORE' AT T1 OR T2;

*RECORD COUNT GOES FROM 138,955 TO 134,193;
Data STRESS_First_Last_Final2;
set STRESS_First_Last_Final;


*ONLY RECORDS WITH POPULATED FIRST AND LAST STRESS COMPOSITE SCORES WILL BE USED IN ANALYSIS OF ASSOCIATED DOLLAR SAVINGS;
if stress_composite_First = . then delete;
if stress_composite_Last = . then delete;
run;




proc freq data=STRESS_First_Last_Final;
table stress_composite_First stress_composite_Last Risk_First Risk_Last;
run;


proc means mean data=STRESS_First_Last_Final;
var stress_composite_First stress_composite_Last;
run;



*****************************************************************;

Data STRESS_working_risk1;
set STRESS_First_Last_Final2;

*SET RISK DEPENDING ON QUESTION RESPONSE;

*THIS SETS THE RISK FLAGS IN EACH TIME PERIOD, BASED ON THE REFERENCE RULE BEING USED;
if stress_composite_First > 3 then Risk_First = 1;
if stress_composite_Last > 3 then Risk_Last = 1;

run;

*ALL RECORDS ARE FLAGGED AS 'AT RISK' SINCE THE FLAG HAS BEEN SET SO LOW (>3), AS DEFINED IN METHODOLOGY;
proc freq data=STRESS_working_risk1;
table Risk_First Risk_Last;
title 'Comparison of STRESS Risk Flags from First and Last Reading';
run;

proc means mean data=STRESS_working_risk1;
var stress_composite_First stress_composite_Last;
run;

*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE BMI RISK REDUCING NUMBER OF DRINKS;
Data STRESS_working_risk2(keep=guid gender2 stress_composite_First stress_composite_Last Risk_First Risk_Last Stress_Value_per_Risk Impact1 Risk_Last_Updated
                               agegroup year_first year_last year_in_pgm item change_in_STRESS);
set STRESS_working_risk1;

Stress_Value_per_Risk = 169.0;

Impact1 = 0;


*ALL MEMBERS HAVE RISK_FLAG AT TIME1 AND TIME2, JUST USING THE INCREMENTAL CALCULATION FOR IMPACT;


*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;

*DECREASED RISK - STRESS COMPOSITE GONE DOWN;
if Risk_First = 1 and Risk_Last = 1 and change_in_STRESS = 'decreased' then DO;
Impact1 = (stress_composite_First - stress_composite_Last) / (stress_composite_First - 3);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASED RISK - STRESS COMPOSITE GONE UP;
if Risk_First = 1 and Risk_Last = 1 and change_in_STRESS = 'increased' then DO;
Impact1 = (stress_composite_First - stress_composite_Last) / (40.0 - stress_composite_First);
Risk_Last_Updated = (1 - Impact1);
END;

*NO CHANGE RISK - STRESS COMPOSITE GONE UP;
if Risk_First = 1 and Risk_Last = 1 and change_in_STRESS = 'no change' then DO;
Impact1 = (stress_composite_First - stress_composite_Last) / (40.0 - stress_composite_First);
Risk_Last_Updated = (1 - Impact1);
END;


format Stress_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;


****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table STRESS_working_risk2 as 
select a.*, b.cost as SIMM_value_risk
from STRESS_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN TOTAL CHOLESTEROL RISK;
Data STRESS_working_risk3;
set STRESS_working_risk2;


*if Impact1 gt 0 then DO;
STRESS_Impact_Savings = Impact1*STRESS_Value_per_Risk;
*END;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
STRESS_Impact_Savings2 = Impact1*SIMM_value_risk;



format STRESS_Impact_Savings STRESS_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCATIED WITH CHANGE IN TOTAL CHOLESTEROL;

proc freq data=STRESS_working_risk3;
table BMI_Impact_Savings BMI_Impact_Savings2;
title 'SHBP - Frequency of BMI Impact'; 
run;

proc means sum data=STRESS_working_risk3;
var STRESS_Impact_Savings STRESS_Impact_Savings2;
title 'Final Result for SHBP STRESS Analysis';
run;
