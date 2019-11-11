

*HDL CHOLESTEROL RISK MEASURE;


*353,492 RECORDS PULLED;
proc sql;
create table SHBP_HDL_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'HDL'
order by calculated DOS
;
quit;

****************************************************************;
*GET FIRST AND LAST SYSTOLIC TOTAL CHOLESTEROL READINGS;

proc sort data=SHBP_HDL_records;
by GUID DOS;
run;

*153,704 RECORDS;
Data HDL_first;
set SHBP_HDL_records;
by guid;
if first.guid;
run;

*153,704 RECORDS;
Data HDL_last;
set SHBP_HDL_records;
by guid;
if last.guid;
run;

*97,570 RECORDS;
proc sql;
create table HDL_first_last as
select 	a.guid, 
		a.TestName,
		a.DOS as Date_First,
		a.Year as Year_First,
		input(a.TestResultValue, 5.) as HDL_First,
		0 as Risk_First,
		b.DOS as Date_Last,
		b.Year as Year_Last,
		input(b.TestResultValue, 5.) as HDL_Last,
		0 as Risk_Last
from HDL_first a inner join HDL_last b
on a.guid = b.guid
where a.DOS <> b.DOS;
quit;


*DELETE RECORD IF YEAR_FIRST = YEAR_LAST;
*97,570 RECORDS TO 97,094 RECORDS;
Data HDL_first_last;
set HDL_first_last;

if Year_First = Year_Last then delete;
run;


*****************************************************************;

*97,094 DISTINCT MEMBERS;
proc sql;
select count(distinct guid) as member_count
from HDL_first_last
;
quit;

*RECORDS ARE FROM 2014 TO 2018, SO NO RECORDS IN 2019 THAT HAVE TO BE DELETED;
proc freq data=HDL_first_last;
table Year_first Year_last;
run;

*****************************************************************;

*BRING IN DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

*TABLE WITH *96,613 RECORDS;
Proc sql;
create table HDL_First_Last_Final as
select distinct a.Guid, b.DOB, 'HDL Cholesterol' as item,
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
  when HDL_Last lt HDL_First then 'decreased'
  when HDL_Last gt HDL_First then 'increased' 
  when HDL_Last = HDL_First then 'no change'
  else 'unknown'
  end as change_in_HDL, a.*
from HDL_first_last a inner join shbp2.shbp_eligibility_unique b
on a.Guid = b.Guid;
quit;


*****************************************************************;


*SET RISK FLAGS, BASED ON FIRST AND LAST HDL READINGS;

Data HDL_working_risk1; 
set HDL_First_Last_Final;

if HDL_First < 35 then Risk_First = 1;

if HDL_Last < 35 then Risk_Last = 1;
run;


proc freq data=HDL_working_risk1;
table Risk_First Risk_Last;
title 'Comparison of HDL Cholesterol Risk Flags from First and Last Reading';
run;


*****************************************************************;


*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data HDL_working_risk2(keep=guid gender2 HDL_First HDL_Last Risk_First Risk_Last HDL_Value_per_Risk Impact1 Risk_Last_Updated 
                            agegroup year_first year_last year_in_pgm item change_in_HDL); 
set HDL_working_risk1;

HDL_Value_per_Risk = 189.0;

Impact1 = 0;


/*

*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;
if Risk_First = 1 and Risk_Last = 1 then DO;
*Impact1 = (HDL_First - HDL_Last) / (35 - HDL_First);
Impact1 = (HDL_First - HDL_Last) / (HDL_First - 35);
Risk_Last_Updated = (1 - Impact1);
END;

*/


*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE LIFE SATISFACTION RISK; 
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP LIFE SATISFACTION RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;


*CODING BELOW ACCOUNTS FOR MEMBERS WHO ARE AT RISK AT T1 AND T2, BUT THEIR RISK LEVEL CHANGES;

/*

*DECREASE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and change_in_HDL = 'increased' then DO;
Impact1 = (HDL_First - HDL_Last) / (HDL_First - 35);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASE IN RISK, OR NO CHANGE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and change_in_HDL in ('decreased','no change') then DO;
Impact1 = (HDL_First - HDL_Last) / (200 - HDL_First);
Risk_Last_Updated = (1 - Impact1);
END;

*/

format HDL_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;

*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table HDL_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from HDL_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;

*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN HDL CHOLESTEROL RISK;
Data HDL_working_risk3;
set HDL_working_risk2_b;


*if Impact1 gt 0 then DO;
HDL_Impact_Savings = Impact1*HDL_Value_per_Risk;
*END;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
HDL_Impact_Savings2 = Impact1*SIMM_value_risk;

format HDL_Impact_Savings HDL_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN HDL CHOLESTEROL;

proc freq data=HDL_working_risk3;
table HDL_Impact_Savings HDL_Impact_Savings2;
title 'SHBP - Frequency of TOTAL CHOL Impact'; 
run;

proc means sum data=HDL_working_risk3;
var HDL_Impact_Savings HDL_Impact_Savings2;
title 'Final Result for SHBP HDL CHOLESTEROL Analysis';
run;

proc sort data=HDL_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP HDL CHOLESTEROL Savings by Last Year of Shown on Record';
select year_last, count(*) as rec_count, sum(HDL_Impact_Savings) as savings_amount format=DOLLAR10.2
from HDL_working_risk3
group by year_last
;
quit;

proc sql;
title 'Sum of SHBP HDL CHOLESTEROL Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(HDL_Impact_Savings) as savings_amount format=DOLLAR10.2
from HDL_working_risk3
group by year_first, year_last
;
quit;


**********************************************************************************************************;
**********************************************************************************************************;
**********************************************************************************************************;
**********************************************************************************************************;

*THIS CODING BELOW WORKS TO USE THE INCREMENTAL CHANGE FOR THOSE MEMBERS WHO STAY AT RISK,
BUT WHO HAVE AN INCREMENTAL CHANGE IN RISK;



*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data HDL_working_risk2_INC(keep=guid gender2 HDL_First HDL_Last Risk_First Risk_Last HDL_Value_per_Risk Impact1 Risk_Last_Updated 
                            agegroup year_first year_last year_in_pgm item change_in_HDL); 
set HDL_working_risk1;

HDL_Value_per_Risk = 189.0;

Impact1 = 0;


/*

*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;
if Risk_First = 1 and Risk_Last = 1 then DO;
*Impact1 = (HDL_First - HDL_Last) / (35 - HDL_First);
Impact1 = (HDL_First - HDL_Last) / (HDL_First - 35);
Risk_Last_Updated = (1 - Impact1);
END;

*/


*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE LIFE SATISFACTION RISK; 
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP LIFE SATISFACTION RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;


*CODING BELOW ACCOUNTS FOR MEMBERS WHO ARE AT RISK AT T1 AND T2, BUT THEIR RISK LEVEL CHANGES;

*DECREASE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and change_in_HDL = 'increased' then DO;
Impact1 = (HDL_First - HDL_Last) / (HDL_First - 35);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASE IN RISK, OR NO CHANGE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and change_in_HDL in ('decreased','no change') then DO;
Impact1 = (HDL_First - HDL_Last) / (0 - HDL_First);
Risk_Last_Updated = (1 - Impact1);
END;

format HDL_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;

*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table HDL_working_risk2_INC_b as 
select a.*, b.cost as SIMM_value_risk
from HDL_working_risk2_INC a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;

*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN HDL RISK;
Data HDL_working_risk3_INC;
set HDL_working_risk2_INC_b;


*if Impact1 gt 0 then DO;
HDL_Impact_Savings = Impact1*HDL_Value_per_Risk;
*END;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
HDL_Impact_Savings2 = Impact1*SIMM_value_risk;

format HDL_Impact_Savings HDL_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN HDL CHOLESTEROL;

proc freq data=HDL_working_risk3_INC;
table HDL_Impact_Savings HDL_Impact_Savings2;
title 'SHBP - Frequency of TOTAL CHOL Impact'; 
run;

proc means sum data=HDL_working_risk3_INC;
var HDL_Impact_Savings HDL_Impact_Savings2;
title 'Final Result for SHBP HDL CHOLESTEROL Analysis';
title 'Incremental Risk Added to HDL Coding';
run;
