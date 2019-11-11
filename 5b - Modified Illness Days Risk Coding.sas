
*ILLNESS DAYS RISK MEASURE CODING;

*PULL ILLNESS DAYS RISK RECORDS FROM REALAGE AND THE WBA;

*RealAge; *130,252 RECORDS;
proc sql;
create table Illness_RealAge as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 20513
order by guid, from_date 
;
quit;


*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
*WBA; *482,431 RECORDS;
proc sql;
create table Illness_WBA as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844297350 
;
quit;

*******************************************************************************************;

*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table ILLNESS_RealAge_reponses as
select distinct fact_value
from Illness_RealAge;
quit;


proc sql;
create table ILLNESS_WBA_reponses as
select distinct response_text
from Illness_WBA;
quit;

proc freq data=Illness_RealAge;
table fact_value;
title 'Realage Responses for Illness Days';
quit;

proc freq data=Illness_WBA;
table response_text;
title 'WBA Responses for Illness Days';
quit;

/* RealAge: fact_values 

11to15 
16Plus 
1to2  
3to5 
6to10 
none 
Frequency Missing = 1357 


WBA: Response Texts
0 days 
1 - 2 days 
11 - 15 days 
16 days or more
3 - 5 days 
6 - 10 days 

*/ 


Data ILLNESS_RealAge_recode1;
set Illness_RealAge;
if fact_value = 'none' then fact_value = '0 days';
if fact_value = '1to2' then fact_value = '1 - 2 days';
if fact_value = '3to5' then fact_value = '3 - 5 days';
if fact_value = '6to10' then fact_value = '6 - 10 days';
if fact_value = '11to15' then fact_value = '11 - 15 days';
if fact_value = '16Plus' then fact_value = '16 days or more';
run;


Data ILLNESS_RealAge_recode2 (rename =  (fact_id=asmnt_question_id fact_value=response_text from_date=response_date2)) ;
set ILLNESS_RealAge_recode1;
run;

proc freq data=ILLNESS_RealAge_recode2;
table year;
run;

*RECORDS IN THE REALAGE TABLE WITH YEAR GREATHER THAN 2018 ARE DELETED;
*TABLE GOES FROM 130,252 to 81,022;
Data ILLNESS_RealAge_recode3;
set ILLNESS_RealAge_recode2;

if year le 2018;
run;


*****************************************************************;

*MERGE REALGE AND WBA PHYSICAL ACTIVITY DATASETS;
Data Illness_merged;
set  Illness_WBA ILLNESS_RealAge_recode3;
run;

proc freq data=Illness_merged;
table response_text;
run;
*****************************************************************;


*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=Illness_merged;
by guid response_date2;
run;


*ILLNESS First value;
*N=214,636 RECORDS;
Data Illness_first;
set Illness_merged;
by guid;
if first.guid;
run;

*ILLNESS Last value;
*N=214,636 RECORDS;
Data Illness_last;
set Illness_merged;
by guid;
if last.guid;
run;

*JOIN BOTH FIRST AND LAST ILLNESS RECORD FILES;
*140,710 RECORDS IN TABLE;
proc sql;
create table ILLNESS_first_last as
select 	a.guid, 
		'Illness Days' as item,
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
from Illness_first a inner join Illness_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*140,710 RECORDS TO 140,277 RECORDS;
Data ILLNESS_first_last;
set ILLNESS_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;



*BRING DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

Data ILLNESS_first_last2;
set ILLNESS_first_last;
Guid_num = Guid*1;
run;

*TABLE WITH 140,247 RECORDS PRODUCED;
Proc sql;
create table ILLNESS_First_Last_Final as
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
from ILLNESS_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = ILLNESS_First_Last_Final;
table gender Gender2;
run;


*****************************************************************;

*SET RISK DEPENDING ON GENDER AND THE AMOUNT OF ALCOHOL DRINKS BEING CONSUMED;

proc freq data=ILLNESS_First_Last_Final;
table value_first value_last Risk_First Risk_Last;
run;

Data ILLNESS_working_risk1;
set ILLNESS_First_Last_Final;

if Value_First = '6 - 10 days' then Risk_First = 1;
else if Value_First = '11 - 15 days' then Risk_First = 1;
else if Value_First = '16 days or more' then Risk_First = 1;
else Risk_First = 0;


if Value_Last = '6 - 10 days' then Risk_Last = 1;
else if Value_Last = '11 - 15 days' then Risk_Last = 1;
else if Value_Last = '16 days or more' then Risk_Last = 1;
else Risk_Last = 0;

run;


proc freq data=ILLNESS_working_risk1;
table value_first value_last Risk_First Risk_Last;
title 'Risk Flags for Illness Days';
run;


*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data ILLNESS_working_risk2; /*(keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact1 Risk_Last_Updated);*/ 
set ILLNESS_working_risk1;

ILLNESS_Value_per_Risk = 137.0;

Impact1 = 0;

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE ACTIVITY RISK;
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP ACTIVITY RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;

format ILLNESS_Value_per_Risk DOLLAR10.2;
format Impact1 6.3;

run;

*****************************************************************;


*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table ILLNESS_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from ILLNESS_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


*****************************************************************;

*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;

*RECORD COUNT GOES FROM 140,227 TO 139,985 WHEN TAKE OUT RECORDS WITH A NULL FIRST OR LAST VALUE;
Data ILLNESS_working_risk3;
set ILLNESS_working_risk2_b;

if value_first = '' then delete;
if value_last = '' then delete;

ILLNESS_Impact_Savings = Impact1*ILLNESS_Value_per_Risk;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
ILLNESS_Impact_Savings2 = Impact1*SIMM_value_risk;

format ILLNESS_Impact_Savings ILLNESS_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN ILLNESS DAYS RISK;

proc freq data=ILLNESS_working_risk3;
table ILLNESS_Impact_Savings ILLNESS_Impact_Savings2;
title 'SHBP - Frequency of ILLNESS DAYS Impact'; 
run;

proc means sum data=ILLNESS_working_risk3;
var ILLNESS_Impact_Savings ILLNESS_Impact_Savings2;
title ' Final Result for SHBP ILLNESS DAYS Analysis';
*where value_first ne '' and value_last ne '';
run;


proc sort data=ILLNESS_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP ILLNESS_DAYS Savings by Last Year Shown on Record';
select year_last, count(*) as rec_count, sum(ILLNESS_Impact_Savings) as savings_amount format=DOLLAR10.2
from ILLNESS_working_risk3
group by year_last
;
quit;


