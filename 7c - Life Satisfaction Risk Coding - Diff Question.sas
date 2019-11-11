*LIFE SATISFACTION RISK MEASURE CODING -- DIFFERENT QUESTION IS BEING USED FROM PROGRAM 7b;

*QUESTION BEING USED
In general, how satisfied are you with your life (include personal and professional aspects)?


*PULL LIFE SATISFACTION RISK RECORDS FROM REALAGE AND THE WBA;

*128,585 RECORDS;
proc sql;
create table LIFE_RealAge2 as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 20510
order by guid, from_date 
;
quit;


*THIS PRODUCES COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
*WBA; *482,431 RECORDS;
proc sql;
create table LIFE_WBA2 as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844297000
;
quit;

*******************************************************************************************;


*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table LIFE_RealAge_reponses2 as
select distinct fact_value
from LIFE_RealAge2;
quit;


proc sql;
create table LIFE_WBA_reponses2 as
select distinct response_text
from LIFE_WBA2;
quit;

proc freq data=LIFE_RealAge2;
table fact_value;
title 'Realage Responses for LIFE SATISFACTION';
quit;

proc freq data=LIFE_WBA2;
table response_text;
title 'WBA Responses for LIFE SATISFACTION';
quit;

/* RealAge: fact_values 

completely 
mostly 
notSatisfied 
partly 




WBA: Response Texts

Completely satisfied  
Mostly satisfied 
Not satisfied 
Partly satisfied 

*/ 


Data LIFE_RealAge_recode1;
set LIFE_RealAge2;
if fact_value = 'completely' then fact_value = 'Completely satisfied';
if fact_value = 'mostly' then fact_value = 'Mostly satisfied';
if fact_value = 'notSatisfied' then fact_value = 'Not satisfied';
if fact_value = 'partly' then fact_value = 'Partly satisfied';
run;


proc freq data=LIFE_RealAge_recode1;
table fact_value;
run;

proc freq data=LIFE_WBA2;
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
set LIFE_WBA2 LIFE_RealAge_recode3; 
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

if response_text = 'Completely satisfied' then response_text_num = 1;
else if response_text = 'Mostly satisfied' then response_text_num = 2;
else if response_text = 'Partly satisfied' then response_text_num = 3;
else if response_text = 'Not satisfied' then response_text_num = 4;
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
*N=215,301 RECORDS;
Data LIFE_first;
set LIFE_merged2;
by guid;
if first.guid;
run;

*LIFE SATISFACTION Last value;
*N=215,301 RECORDS;
Data LIFE_last;
set LIFE_merged2;
by guid;
if last.guid;
run;

*JOIN BOTH FIRST AND LAST ALCOHOL RECORD FILES;
*141,121 RECORDS IN TABLE;
proc sql;
create table LIFE_first_last as
select 	a.guid, 
		'Life Satisfaction' as item,
		a.asmnt_question_id as Question_fact_id_First,
		a.response_date2 as Date_First,
		a.Year as Year_First,
		a.response_text as Value_First,
		a.response_text_num as Value_First_num,
		0 as Risk_First,
		b.asmnt_question_id as Question_fact_id_Last,
		b.response_date2 as Date_Last,
		b.Year as Year_Last,
		b.response_text as Value_Last,
		b.response_text_num as Value_Last_num,
		0 as Risk_Last
from LIFE_first a inner join LIFE_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*141,121 RECORDS TO 140,710 RECORDS;
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

*TABLE WITH 140,680 RECORDS PRODUCED;
Proc sql;
create table LIFE_First_Last_Final_difques as
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
  end as year_in_pgm, a.*
from LIFE_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = LIFE_First_Last_Final_difques;
table gender Gender2;
run;


*****************************************************************;


*SET RISK DEPENDING ON QUESTION RESPONSE;
proc freq data=LIFE_First_Last_Final_difques;
table value_first value_last Risk_First Risk_Last;
run;


Data LIFE_working_risk1_DQ;
set LIFE_First_Last_Final_difques;


if Value_First = 'Partly satisfied' then Risk_First = 1;
else if Value_First = 'Not satisfied' then Risk_First = 1;
else Risk_First = 0;

if Value_Last = 'Partly satisfied' then Risk_Last = 1;
else if Value_Last = 'Not satisfied' then Risk_Last = 1;
else Risk_Last = 0;


satisfaction_level_change = Value_Last_num - Value_First_num;

run;


proc freq data=LIFE_working_risk1_difquest;
table value_first value_last Risk_First Risk_Last;
run;


*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;
Data LIFE_working_risk2_DQ(keep=guid gender2 Value_First Value_Last Risk_First Risk_Last LIFE_Value_per_Risk Impact1 Risk_Last_Updated year_first year_last
                                year_first year_last satisfaction_level_change AgeGroup year_in_pgm item);  
set LIFE_working_risk1_DQ;

LIFE_Value_per_Risk = 135.0;

Impact1 = 0;

/*
*THIS IS CODE THAT WORKS TO CALCULATE THE INCREMENTAL RISK THAT WE WILL USE ATTRIBUTE SAVINGS OR FURTHER EXPENSE
TO THOSE MEMBERS WHO STAY AT RISK AT T1 AND T2;
if Risk_First = 1 and Risk_Last = 1 then DO;
Impact1 = (Value_Last - Value_First) / (7 - Value_First);
Risk_Last_Updated = (1 - Impact1);
END;
*/

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE LIFE SATISFACTION RISK; 
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP LIFE SATISFACTION RISK;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;



*I AM SETTING IMPACT BELOW, BASED ON EXAMPLE SHOWN IN THE HEALTHWAYS ROI METHODOLOGY REFERENCE
GUIDE (UPDATED AUGUST 8, 2016);

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH RISK AT T1 & T2, AND DECREASE THEIR 'LIFE SATISFACTION' RISK
FROM T1 TO T2;
If Risk_First = 1 and Risk_Last = 1 and Value_First = 'Not satisfied' and Value_Last = 'Partly satisfied' then Impact1 = 1.0;


*THIS LINE BELOW TAKES CARE OF MEMBERS WITH RISK AT T1 & T2, AND INCREASE THEIR 'LIFE SATISFACTION' RISK
FROM T1 TO T2;
If Risk_First = 1 and Risk_Last = 1 and Value_First = 'Partly satisfied' and Value_Last = 'Not satisfied' then Impact1 = -1.0;


*NOT GOING TO USE THIS CODE BELOW;
/*
*CODING BELOW ACCOUNTS FOR MEMBERS WHO ARE AT RISK AT T1 AND T2, BUT THEIR RISK LEVEL CHANGES;
*DECREASE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and satisfaction_level_change gt 0 then DO;
Impact1 = (Value_First - Value_Last) / (Value_First - 7);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASE IN RISK, OR NO CHANGE IN RISK;
if Risk_First = 1 and Risk_Last = 1 and satisfaction_level_change le 0 then DO;
Impact1 = (Value_Last - Value_First) / (Value_First-0);  
Risk_Last_Updated = (1 - Impact1);
END;

*/

format LIFE_Value_per_Risk DOLLAR10.2;
*format Impact1 Risk_Last_Updated 6.3;

run;
*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table LIFE_working_risk2_DQ_b as 
select a.*, b.cost as SIMM_value_risk
from LIFE_working_risk2_DQ a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


proc freq data=LIFE_working_risk2_DQ_b;
table impact1;
run;
*****************************************************************;


*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;
Data LIFE_working_risk3_DQ;
set LIFE_working_risk2_DQ_b;


*if Impact1 gt 0 then DO;
LIFE_Impact_Savings = Impact1*LIFE_Value_per_Risk;
*END;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
LIFE_Impact_Savings2 = Impact1*SIMM_value_risk;

format LIFE_Impact_Savings LIFE_Impact_Savings2 DOLLAR10.2;
run;

*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN USE OF ALCOHOL;

proc freq data=LIFE_working_risk3_DQ;
table LIFE_Impact_Savings;
title 'SHBP - Frequency of Alcohol Impact'; 
run;

proc means sum data=LIFE_working_risk3_DQ;
var LIFE_Impact_Savings LIFE_Impact_Savings2;
title 'Final Result for SHBP LIFE SATISFACTION Analysis';
run;

proc sort data=LIFE_working_risk3_DQ;
by Year_Last;
run;

proc sql;
title 'Sum of SHBP Alcohol Savings by Last Year of Shown on Record';
select year_last, count(*) as rec_count, sum(LIFE_Impact_Savings) as savings_amount format=DOLLAR10.2
from LIFE_working_risk3_DQ
group by year_last
;
quit;

proc sql;
title 'Sum of SHBP Alcohol Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(LIFE_Impact_Savings) as savings_amount format=DOLLAR10.2
from LIFE_working_risk3_DQ
group by year_first, year_last
;
quit;

