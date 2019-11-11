
*PHYSICAL ACTIVITY METRIC FOR SHBP;

*REALAGE - 134,129 RECORDS;
*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
proc sql;
create table ACTIVITY_RealAge as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 20514 
order by guid, from_date 
;
quit;


*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
*WBA; *482,431 RECORDS;
proc sql;
create table ACTIVITY_WBA as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844297710 
;
quit;


*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table Activity_RealAge_reponses as
select distinct fact_value
from Activity_RealAge;
quit;


proc sql;
create table Activity_WBA_reponses as
select distinct response_text
from Activity_WBA;
quit;

proc freq data=ACTIVITY_RealAge;
table fact_value;
title 'Realage Responses for Physical Activity';
quit;

proc freq data=ACTIVITY_WBA;
table response_text;
title 'WBA Responses for Physical Activity';
quit;

/* RealAge: fact_values 

lessThan1
mod1to4
mod5Plus
none
vigor1to2                    
vigor3Plus

WBA: Response Texts
I do not exercise reg      
Moderate: 1-4 times p      
Moderate: 5 or more t       
On average, less than       
Vigorous: 1-2 times p      
Vigorous: 3 or more t  

*/ 


Data ACTIVITY_RealAge_recode1;
set Activity_RealAge;
if fact_value = 'none' then fact_value = 'I do not exercise reg';
if fact_value = 'lessThan1' then fact_value = 'On average, less than';
if fact_value = 'mod1to4' then fact_value = 'Moderate: 1-4 times p';
if fact_value = 'mod5Plus' then fact_value = 'Moderate: 5 or more t';
if fact_value = 'vigor1to2' then fact_value = 'Vigorous: 1-2 times p';
if fact_value = 'vigor3Plus' then fact_value = 'Vigorous: 3 or more t';
run;


Data ACTIVITY_RealAge_recode2 (rename =  (fact_id=asmnt_question_id fact_value=response_text from_date=response_date2)) ;
set ACTIVITY_RealAge_recode1;
run;

proc freq data=ACTIVITY_RealAge_recode2;
table year;
run;

*RECORDS IN THE REALAGE TABLE WITH YEAR GREATHER THAN 2018 ARE DELETED;
*TABLE GOES FROM 134,129 to 82,258;
Data ACTIVITY_RealAge_recode3;
set ACTIVITY_RealAge_recode2;

if year le 2018;
run;


*****************************************************************;

*MERGE  REALGE AND WBA PHYSICAL ACTIVITY DATASETS;
Data Physical_Activity;
set  ACTIVITY_WBA ACTIVITY_RealAge_recode3;
run;


*****************************************************************;

*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=Physical_Activity;
by guid response_date2;
run;


*Physical_Activity First value;
*N=214,613 RECORDS;
Data Activity_first;
set Physical_Activity;
by guid;
if first.guid;
run;

*Physical_Activity Last value;
*N=214,613 RECORDS;
Data Activity_last;
set Physical_Activity;
by guid;
if last.guid;
run;

*JOIN BOTH FIRST AND LAST ALCOHOL RECORD FILES;
*140,835 RECORDS IN TABLE;
proc sql;
create table ACTIVITY_first_last as
select 	a.guid, 
		'Physical Activity' as item,
		a.asmnt_question_id as Question_fact_id_First,
		a.response_date2 as Date_First,
		a.Year as Year_First,
		a.response_text as Value_First,
		0 as Risk_First,
		b.asmnt_question_id as Question_fact_id_Last,
		b.response_date2 as Date_Last,
		b.Year as Year_Last,
		b.response_text as Value_Last,
		0 as Risk_Last
from Activity_first a inner join Activity_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*140,835 RECORDS TO 140,259 RECORDS;
Data ACTIVITY_first_last;
set ACTIVITY_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;


*BRING DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

Data ACTIVITY_first_last2;
set ACTIVITY_first_last;
Guid_num = Guid*1;
run;

*TABLE WITH 140,229 RECORDS PRODUCED;
Proc sql;
create table ACTIVITY_First_Last_Final as
select a.Guid, a.Guid_num, b.DOB, 
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
  end as year_in_pgm, a.*
from ACTIVITY_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = ACTIVITY_First_Last_Final;
table gender Gender2;
run;


*****************************************************************;

*SET RISK DEPENDING ON GENDER AND THE AMOUNT OF ALCOHOL DRINKS BEING CONSUMED;

proc freq data=ACTIVITY_First_Last_Final;
table value_first value_last;
run;

Data ACTIVITY_working_risk1;
set ACTIVITY_First_Last_Final;

if Value_First = 'I do not exercise reg' then Risk_First = 1;
else if Value_First = 'On average, less than' then Risk_First = 1;
else if Value_First = 'Moderate: 1-4 times p' then Risk_First = 0;
else if Value_First = 'Vigorous: 1-2 times p' then Risk_First = 0;
else Risk_First = 0;


if Value_Last = 'I do not exercise reg' then Risk_Last = 1;
else if Value_Last = 'On average, less than' then Risk_Last = 1;
else if Value_Last = 'Moderate: 1-4 times p' then Risk_Last = 0;
else if Value_Last = 'Vigorous: 1-2 times p' then Risk_Last = 0;
else Risk_Last = 0;

run;


proc freq data=ACTIVITY_working_risk1;
table value_first value_last Risk_First Risk_Last;
title 'Risk Flags at T1 and T2 for Physical Activity';
run;

*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data ACTIVITY_working_risk2; /*(keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact1 Risk_Last_Updated);*/ 
set ACTIVITY_working_risk1;

Activity_Value_per_Risk = 54.0;

Impact1 = 0;

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE ACTIVITY RISK;
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP ACTIVITY RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;

format Activity_Value_per_Risk DOLLAR10.2;
format Impact1 6.3;

run;
*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table ACTIVITY_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from ACTIVITY_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;

*RECORD COUNT GOES FROM 140,229 TO 139,973 WHEN TAKE OUT RECORDS WITH A NULL FIRST OR LAST VALUE;
Data ACTIVITY_working_risk3;
set ACTIVITY_working_risk2_b;

*ONLY RECORDS WITH POPULATED FIRST AND LAST VALUES WILL BE USED IN OBTAINING ASSOCIATED DOLLAR SAVINGS;
if value_first = '' then delete;
if value_last = '' then delete;

Activity_Impact_Savings = Impact1*Activity_Value_per_Risk;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
Activity_Impact_Savings2 = Impact1*SIMM_value_risk;

format Activity_Impact_Savings Activity_Impact_Savings2 DOLLAR10.2;
run;


*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN PHYSICAL ACTIVITY;

proc freq data=ACTIVITY_working_risk3;
table Activity_Impact_Savings;
title 'SHBP - Frequency of Physical Activity Impact'; 
run;

proc means sum data=ACTIVITY_working_risk3;
var Activity_Impact_Savings Activity_Impact_Savings2;
title ' Final Result for SHBP Physical Activity Analysis';
run;


proc sort data=ACTIVITY_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP Activity Savings by Last Year Shown on Record';
select year_last, count(*) as rec_count, sum(Activity_Impact_Savings) as savings_amount format=DOLLAR10.2
from ACTIVITY_working_risk3
group by year_last
;
quit;


