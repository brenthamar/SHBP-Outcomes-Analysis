

*SMOKING RISK MEASURE CODING;


*PULL SMOKING RISK RECORDS FROM REALAGE AND THE WBA;

*RealAge; *120,049 RECORDS;
proc sql;
create table SMOKE_RealAge as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 20008
order by guid, from_date 
;
quit;


*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
*WBA; *482,431 RECORDS;
proc sql;
create table SMOKE_WBA as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844297640
;
quit;

*******************************************************************************************;

*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table SMOKE_RealAge_reponses as
select distinct fact_value
from SMOKE_RealAge;
quit;


proc sql;
create table SMOKE_WBA_reponses as
select distinct response_text
from SMOKE_WBA;
quit;

proc freq data=SMOKE_RealAge;
table fact_value;
title 'Realage Responses for SMOKING';
quit;

proc freq data=SMOKE_WBA;
table response_text;
title 'WBA Responses for SMOKING';
quit;

/* RealAge: fact_values 

dontKnow 
no 
yes 
 
Frequency Missing = 1465 


WBA: Response Texts
Don't know 
No  
Yes  

*/

Data SMOKE_RealAge_recode1;
set SMOKE_RealAge;
if fact_value = 'dontKnow' then fact_value = 'DontKnow';
if fact_value = 'no ' then fact_value = 'No';
if fact_value = 'yes' then fact_value = 'Yes';
run;

Data SMOKE_WBA_recode1;
set SMOKE_WBA;
if response_text = "Don't know" then response_text = 'DontKnow';
run;


proc freq data=SMOKE_RealAge_recode1;
table fact_value;
run;

proc freq data=SMOKE_WBA_recode1;
table response_text;
run;





Data SMOKE_RealAge_recode2 (rename =  (fact_id=asmnt_question_id fact_value=response_text from_date=response_date2)) ;
set SMOKE_RealAge_recode1;
run;

proc freq data=SMOKE_RealAge_recode2;
table year;
run;
 

*RECORDS IN THE REALAGE TABLE WITH YEAR GREATHER THAN 2018 ARE DELETED;
*TABLE GOES FROM 120,049 to 90,864;
Data SMOKE_RealAge_recode3;
set SMOKE_RealAge_recode2;

if year le 2018;
run;


*****************************************************************;

*MERGE REALGE AND WBA SMOKING DATASETS;
Data SMOKE_merged;
set  SMOKE_WBA_recode1 SMOKE_RealAge_recode3;
run;

proc freq data=SMOKE_merged;
table response_text;
run;


*572,176 RECORDS;
Data SMOKE_merged2;
set SMOKE_merged;

*DO NOT USE ANY RECORDS WITH NO RESPONSE OR DONT KNOW TO THE SMOKING QUESTION;
if response_text in ('', 'DontKnow') then delete;
run;


*****************************************************************;




*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=SMOKE_merged2;
by guid response_date2;
run;


*SMOKE First value;
*N=216,129 RECORDS;
Data SMOKE_first;
set SMOKE_merged2;
by guid;
if first.guid;
run;

*SMOKE Last value;
*N=216,129 RECORDS;
Data SMOKE_last;
set SMOKE_merged2;
by guid;
if last.guid;
run;

*JOIN BOTH FIRST AND LAST SMOKE RECORD FILES;
*141,543 RECORDS IN TABLE;
proc sql;
create table SMOKE_first_last as
select 	a.guid, 
		'Smoking' as item,
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
from SMOKE_first a inner join SMOKE_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*141,543 RECORDS TO 141,308 RECORDS;
Data SMOKE_first_last;
set SMOKE_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;
*****************************************************************;

*BRING DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

Data SMOKE_first_last2;
set SMOKE_first_last;
Guid_num = Guid*1;
run;

*TABLE WITH 141,278 RECORDS PRODUCED;
Proc sql;
create table SMOKE_First_Last_Final as
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
from SMOKE_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = SMOKE_First_Last_Final;
table gender Gender2;
run;


*****************************************************************;


*SET RISK DEPENDING ON QUESTION RESPONSE;

proc freq data=SMOKE_First_Last_Final;
table value_first value_last Risk_First Risk_Last;
run;

Data SMOKE_working_risk1;
set SMOKE_First_Last_Final;

if Value_First = 'Yes' then Risk_First = 1;
else if Value_First = 'No' then Risk_First = 0;


if Value_Last = 'Yes' then Risk_Last = 1;
else if Value_Last = 'No' then Risk_Last = 0;

run;


proc freq data=SMOKE_working_risk1;
table value_first value_last Risk_First Risk_Last;
run;

*****************************************************************;


*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data SMOKE_working_risk2; /*(keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact1 Risk_Last_Updated);*/ 
set SMOKE_working_risk1;

SMOKE_Value_per_Risk = 305.0;

Impact1 = 0;

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE ACTIVITY RISK;
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP ACTIVITY RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;

format SMOKE_Value_per_Risk DOLLAR10.2;
format Impact1 6.3;

run;

*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table SMOKE_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from SMOKE_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;

*RECORD COUNT STAYS AT 141,278 -- THERE ARE NO NULL VALUES IN THE VALUE FIRST OR LAST CELLS;
Data SMOKE_working_risk3;
set SMOKE_working_risk2_b;

if value_first = '' then delete;
if value_last = '' then delete;

SMOKE_Impact_Savings = Impact1*SMOKE_Value_per_Risk;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
SMOKE_Impact_Savings2 = Impact1*SIMM_value_risk;

format SMOKE_Impact_Savings SMOKE_Impact_Savings2 DOLLAR10.2;
run;


*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN SMOKING;

proc freq data=SMOKE_working_risk3;
table SMOKE_Impact_Savings SMOKE_Impact_Savings2;
title 'SHBP - Frequency of SMOKING Impact'; 
run;

proc means sum data=SMOKE_working_risk3;
var SMOKE_Impact_Savings SMOKE_Impact_Savings2;
title ' Final Result for SHBP SMOKING Analysis';
run;


proc sort data=SMOKE_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP SMOKING Savings by Last Year Shown on Record';
select year_last, count(*) as rec_count, sum(SMOKE_Impact_Savings) as savings_amount format=DOLLAR10.2
from SMOKE_working_risk3
group by year_last
;
quit;


proc sql;
title 'Sum of SHBP SMOKING Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(SMOKE_Impact_Savings) as savings_amount format=DOLLAR10.2
from SMOKE_working_risk3
group by year_first, year_last
;
quit;
