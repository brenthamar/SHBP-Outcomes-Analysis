
*LIFE SATISFACTION RISK MEASURE CODING;


*PULL LIFE SATISFACTION RISK RECORDS FROM REALAGE AND THE WBA;

*RealAge; *142,853 RECORDS;
proc sql;
create table LIFE_RealAge as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 19933
order by guid, from_date 
;
quit;


*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
*WBA; *482,431 RECORDS;
proc sql;
create table LIFE_WBA as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844296980
;
quit;

*******************************************************************************************;


*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table LIFE_RealAge_reponses as
select distinct fact_value
from LIFE_RealAge;
quit;


proc sql;
create table LIFE_WBA_reponses as
select distinct response_text
from LIFE_WBA;
quit;

proc freq data=LIFE_RealAge;
table fact_value;
title 'Realage Responses for LIFE SATISFACTION';
quit;

proc freq data=LIFE_WBA;
table response_text;
title 'WBA Responses for LIFE SATISFACTION';
quit;

/* RealAge: fact_values 

0Worst 
1 
10Best 
2 
3 
4 
5  
6 
7 
8 
9  
dontKnow 

Frequency Missing = 1366


WBA: Response Texts
0 - Worst 
1 
10 
10 - Best 
11 
12 
2 
3  
4  
5 
6  
7  
8 
9  
Don't know  

*/ 


Data LIFE_RealAge_recode1;
set LIFE_RealAge;
if fact_value = '0Worst' then fact_value = '0 - Worst';
if fact_value = '10Best' then fact_value = '10 - Best';
if fact_value = 'dontKnow' then fact_value = 'DontKnow';
run;

*GET RID OF THE APOSTRAPHE IN THE RESPONSE;
Data LIFE_WBA_recode1;
set LIFE_WBA;
if response_text = '10' then response_text = '10 - Best';
if response_text = '11' then response_text = '0 - Worst';
if response_text = '12' then response_text = 'DontKnow';
if response_text = "Don't know" then response_text = 'DontKnow';
run;


proc freq data=LIFE_RealAge_recode1;
table fact_value;
run;

proc freq data=LIFE_WBA_recode1;
table response_text;
run;


Data LIFE_RealAge_recode2 (rename =  (fact_id=asmnt_question_id fact_value=response_text from_date=response_date2)) ;
set LIFE_RealAge_recode1;
run;

proc freq data=LIFE_RealAge_recode2;
table year;
run;

*RECORDS IN THE REALAGE TABLE WITH YEAR GREATHER THAN 2018 ARE DELETED;
*TABLE GOES FROM 142,853 to 95,634;
Data LIFE_RealAge_recode3;
set LIFE_RealAge_recode2;

if year le 2018;
run;


*****************************************************************;

*MERGE REALGE AND WBA LIFE SATISFACTION DATASETS  - 578,065 RECORDS;

Data LIFE_merged;
set LIFE_WBA_recode1 LIFE_RealAge_recode3; 
run;

*568,697 RECORDS;
Data LIFE_merged;
set LIFE_merged;

*DO NOT USE ANY RECORDS WITH NO RESPONSE TO THE LIFE SATISFACTION QUESTION;
if response_text in ('', 'DontKnow') then delete;
run;


*****************************************************************;

*PRODUCE A NUMERIC RESPONSE VARIABLE, USING THE INITIAL CHARACTER VALUES;

Data LIFE_merged2;
set LIFE_merged;


if response_text = '0 - Worst' then response_text_num = 0;
else if response_text = '1' then response_text_num = 1;
else if response_text = '2' then response_text_num = 2;
else if response_text = '3' then response_text_num = 3;
else if response_text = '4' then response_text_num = 4;
else if response_text = '5' then response_text_num = 5;
else if response_text = '6' then response_text_num = 6;
else if response_text = '7' then response_text_num = 7;
else if response_text = '8' then response_text_num = 8;
else if response_text = '9' then response_text_num = 9;
else if response_text = '10 - Best' then response_text_num = 10;
run;


proc freq data=LIFE_merged2;
table response_text response_text_num;
run;


*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=LIFE_merged2;
by guid response_date2;
run;


*LIFE SATISFACTION First value;
*N=214,171 RECORDS;
Data LIFE_first;
set LIFE_merged2;
by guid;
if first.guid;
run;

*LIFE SATISFACTION Last value;
*N=214,171 RECORDS;
Data LIFE_last;
set LIFE_merged2;
by guid;
if last.guid;
run;

*JOIN BOTH FIRST AND LAST ALCOHOL RECORD FILES;
*140,349 RECORDS IN TABLE;
proc sql;
create table LIFE_first_last as
select 	a.guid, 
		'Life Satisfaction' as item,
		a.asmnt_question_id as Question_fact_id_First,
		a.response_date2 as Date_First,
		a.Year as Year_First,
		a.response_text_num as Value_First,
		0 as Risk_First,
		b.asmnt_question_id as Question_fact_id_Last,
		b.response_date2 as Date_Last,
		b.Year as Year_Last,
		b.response_text_num as Value_Last,
		0 as Risk_Last
from LIFE_first a inner join LIFE_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*140,349 RECORDS TO 139,570 RECORDS;
Data LIFE_first_last;
set LIFE_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;
*****************************************************************;

*BRING DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

Data LIFE_first_last2;
set LIFE_first_last;
Guid_num = Guid*1;
run;

*TABLE WITH 139,540 RECORDS PRODUCED;
Proc sql;
create table LIFE_First_Last_Final as
select a.Guid, a.Guid_num, b.DOB, 
       input( b.DOB, anydtdte24.) as DOB2 format=mmddyy10.,       
       (a.Date_Last - calculated DOB2)/365.25 as Age format=3., 
       b.gender,
  case
  when b.gender = '02' then 'Male'
  when b.gender = '03' then 'Female'
  else 'Unknown'
  end as Gender2, a.*
from LIFE_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = LIFE_First_Last_Final;
table gender Gender2;
run;


*****************************************************************;


*SET RISK DEPENDING ON QUESTION RESPONSE;
proc freq data=LIFE_First_Last_Final;
table value_first value_last Risk_First Risk_Last;
run;


Data LIFE_working_risk1;
set LIFE_First_Last_Final;

if Value_First ge 7 then Risk_First = 0;
else if Value_First lt 7 then Risk_First = 1;


if Value_Last ge 7 then Risk_Last = 0;
else if Value_Last lt 7 then Risk_Last = 1;

run;


proc freq data=LIFE_working_risk1;
table value_first value_last Risk_First Risk_Last;
run;


*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data LIFE_working_risk2(keep=guid gender2 Value_First Value_Last Risk_First Risk_Last LIFE_Value_per_Risk Impact1 Risk_Last_Updated year_first year_last); 
set LIFE_working_risk1;

LIFE_Value_per_Risk = 135.0;

Impact1 = 0;

*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;
if Risk_First = 1 and Risk_Last = 1 then DO;
Impact1 = (Value_Last - Value_First) / (7 - Value_First);
Risk_Last_Updated = (1 - Impact1);
END;


*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE LIFE SATISFACTION RISK; 
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP LIFE SATISFACTION RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;


format LIFE_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;


*****************************************************************;


*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;
Data LIFE_working_risk3;
set LIFE_working_risk2;


*if Impact1 gt 0 then DO;
LIFE_Impact_Savings = Impact1*LIFE_Value_per_Risk;
*END;


format LIFE_Impact_Savings DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCATIED WITH CHANGE IN USE OF ALCOHOL;

proc freq data=LIFE_working_risk3;
table LIFE_Impact_Savings;
title 'SHBP - Frequency of Alcohol Impact'; 
run;

proc means sum data=LIFE_working_risk3;
var LIFE_Impact_Savings;
title 'Final Result for SHBP LIFE SATISFACTION Analysis';
run;

proc sort data=LIFE_working_risk3;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP Alcohol Savings by Last Year of Shown on Record';
select year_last, count(*) as rec_count, sum(LIFE_Impact_Savings) as savings_amount format=DOLLAR10.2
from LIFE_working_risk3
group by year_last
;
quit;

proc sql;
title 'Sum of SHBP Alcohol Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(LIFE_Impact_Savings) as savings_amount format=DOLLAR10.2
from LIFE_working_risk3
group by year_first, year_last
;
quit;

