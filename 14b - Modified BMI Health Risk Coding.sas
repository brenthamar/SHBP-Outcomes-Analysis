
*BMI RISK MEASURE;

*714,996 RECORDS - HEIGHT AND WEIGHT;
proc sql;
create table SHBP_HT_WT_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'HEIGHT'
or TestName = 'WEIGHT'
order by calculated DOS
;
quit;




Data SHBP_HT_WT_records2 (keep=GUID DOS TestName TestResultValue year);
set SHBP_HT_WT_records;
run;

*RECORD COUNT, 714,996 TO 713,521;
proc sort nodupkey data=SHBP_HT_WT_records2 out=SHBP_HT_WT_records2_dedup;
by GUID DOS TestName;
run;



*TRANSPOSE TABLE TO GET DATA INTO PROPER FORMAT;
proc transpose data=SHBP_HT_WT_records2_dedup out=SHBP_HT_WT_records2_dedup_trans;
by GUID DOS year;
id TestName;
var TestResultValue;
run;



*PRODUCE BMI VALUE USING EQUATION;
Data SHBP_BMI;
set SHBP_HT_WT_records2_dedup_trans (drop = _name_);

BMI = (weight/(height*height))*703;

BMI2 = round(BMI,.1);

format BMI 4.1;

run;

****************************************************************;
*GET FIRST AND LAST SYSTOLIC TOTAL CHOLESTEROL READINGS;

proc sort data=SHBP_BMI;
by GUID DOS;
run;

*154,573 RECORDS;
Data BMI_first;
set SHBP_BMI;
by guid;
if first.guid;
run;

*154,573 RECORDS;
Data BMI_last;
set SHBP_BMI;
by guid;
if last.guid;
run;

*98,500 RECORDS;
proc sql;
create table BMI_first_last as
select 	a.guid,
		a.DOS as Date_First,
		a.Year as Year_First,
		a.BMI2 as BMI_First,
		0 as Risk_First,
		b.DOS as Date_Last,
		b.Year as Year_Last,
		b.BMI2 as BMI_Last,
		0 as Risk_Last
from BMI_first a inner join BMI_last b
on a.guid = b.guid
where a.DOS <> b.DOS;
quit;


*DELETE RECORD IF YEAR_FIRST = YEAR_LAST;
*98,500 RECORDS TO 98,017 RECORDS;
Data BMI_first_last;
set BMI_first_last;

if Year_First = Year_Last then delete;
run;


*****************************************************************;

*98,017 DISTINCT MEMBERS;
proc sql;
select count(distinct guid) as member_count
from BMI_first_last
;
quit;

*RECORDS ARE FROM 2014 TO 2018, SO NO RECORDS IN 2019 THAT HAVE TO BE DELETED;
proc freq data=BMI_first_last;
table Year_first Year_last;
run;

*****************************************************************;

*BRING IN DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

*TABLE WITH *97,530 RECORDS;
Proc sql;
create table BMI_First_Last_Final as
select distinct a.Guid, b.DOB, 'BMI' as item,
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
  when BMI_Last lt BMI_First then 'decreased'
  when BMI_Last gt BMI_First then 'increased' 
  when BMI_Last = BMI_First then 'no change'
  else 'unknown'
  end as change_in_BMI, a.*
from BMI_first_last a inner join shbp2.shbp_eligibility_unique b
on a.Guid = b.Guid;
quit;


*****************************************************************;


*SET RISK FLAGS, BASED ON FIRST AND LAST SYSTOLIC/DIASTOLIC READINGS;

Data BMI_working_risk1; 
set BMI_First_Last_Final;

*THIS PRODUCES NEW VALUE VARIABLES, BECAUSE HAVE TO SET VERY HIGH VALUES TO A MAXIMUM DEFINED VALUE;
BMI_First2 = BMI_First;
BMI_Last2 = BMI_Last;

*THIS SETS THE RISK FLAGS IN EACH TIME PERIOD, BASED ON THE REFERENCE RULE BEING USED;
if Gender2 = 'Female' then DO;
if BMI_First > 27.2 then Risk_First = 1;
if BMI_Last > 27.2 then Risk_Last = 1;
END;

if Gender2 = 'Male' then DO;
if BMI_First > 27.7 then Risk_First = 1;
if BMI_Last > 27.7 then Risk_Last = 1;
END;


*THIS SETS THE VERY HIGH BMI VALUES TO MAXIMUM DEFINED VALUE, AS NOTED IN IN THE METHODOLOGY DOCUMENT;
if BMI_First2 gt 45 then BMI_First2 = 45;
if BMI_Last2 gt 45 then BMI_Last2 = 45;

run;


proc freq data=BMI_working_risk1;
table Risk_First Risk_Last;
title 'Comparison of BMI Risk Flags from First and Last Reading';
run;


*****************************************************************;


*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE BMI RISK REDUCING NUMBER OF DRINKS;
Data BMI_working_risk2(keep=guid gender2 BMI_First BMI_Last Risk_First Risk_Last BMI_Value_per_Risk Impact1 Risk_Last_Updated
                            agegroup year_first year_last year_in_pgm item change_in_BMI BMI_First2 BMI_Last2);
set BMI_working_risk1;

BMI_Value_per_Risk = 203.0;

Impact1 = 0;



*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE BMI RISK; 
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP BMI RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;


*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;

*FOR FEMALES;
*DECREASED RISK - BMI GONE DOWN;
if Gender2 = 'Female' and Risk_First = 1 and Risk_Last = 1 and change_in_BMI = 'decreased' then DO;
Impact1 = (BMI_First2 - BMI_Last2) / (BMI_First2 - 27.2);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASED RISK - BMI GONE UP;
if Gender2 = 'Female' and Risk_First = 1 and Risk_Last = 1 and change_in_BMI = 'increased' then DO;
Impact1 = (BMI_First2 - BMI_Last2) / (45.0 - BMI_First2);
Risk_Last_Updated = (1 - Impact1);
END;


*FOR MALES;
*DECREASED RISK - BMI GONE DOWN;
if Gender2 = 'Male' and Risk_First = 1 and Risk_Last = 1 and change_in_BMI = 'decreased' then DO;
Impact1 = (BMI_First2 - BMI_Last2) / (BMI_First2 - 27.7);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASED RISK - BMI GONE UP;
if Gender2 = 'Male' and Risk_First = 1 and Risk_Last = 1 and change_in_BMI = 'increased' then DO;
Impact1 = (BMI_First2 - BMI_Last2) / (45.0 - BMI_First2);
Risk_Last_Updated = (1 - Impact1);
END;


format BMI_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;


****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table BMI_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from BMI_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;



*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN TOTAL CHOLESTEROL RISK;
Data BMI_working_risk3;
set BMI_working_risk2_b;


*if Impact1 gt 0 then DO;
BMI_Impact_Savings = Impact1*BMI_Value_per_Risk;
*END;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
BMI_Impact_Savings2 = Impact1*SIMM_value_risk;



format BMI_Impact_Savings BMI_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCATIED WITH CHANGE IN TOTAL CHOLESTEROL;

proc freq data=BMI_working_risk3;
table BMI_Impact_Savings BMI_Impact_Savings2;
title 'SHBP - Frequency of BMI Impact'; 
run;

proc means sum data=BMI_working_risk3;
var BMI_Impact_Savings BMI_Impact_Savings2;
title 'Final Result for SHBP BMI Analysis';
run;

proc sort data=BMI_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP BMI Savings by Last Year of Shown on Record';
select year_last, count(*) as rec_count, sum(BMI_Impact_Savings) as savings_amount format=DOLLAR10.2
from BMI_working_risk3
group by year_last
;
quit;

proc sql;
title 'Sum of SHBP BMI Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(BMI_Impact_Savings) as savings_amount format=DOLLAR10.2
from BMI_working_risk3
group by year_first, year_last
;
quit;


proc freq data=BMI_working_risk3;
table change_in_BMI;
run;
