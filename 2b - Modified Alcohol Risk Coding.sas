

*WORK ON THE ALCOHOL RISK MEASURE CODING;

*PULL ALCOHOL RISK RECORDS FROM REALAGE AND THE WBA;

*RealAge; *132,326 RECORDS;
data alcohol_RealAge;
set SHBP2.Shbp_realage;
keep guid fact_id fact_value valid_from_date;
where fact_id=20000;
run;

*THIS PRODUCES SAME COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
proc sql;
create table alcohol_RealAge2 as
select customer, guid, fact_id, fact_value,
       valid_from_date, valid_to_date, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id = 20000 
order by guid, from_date 
;
quit;



*WBA; *482,431 RECORDS;
data alcohol_WBA;
set shbp2.WBA_Guid_workaround_2;
keep guid asmnt_question_id response_text response_date;
where asmnt_question_id=6844297730;
run;


*THIS PRODUCES SAME COUNT, AND ALSO FORMATS DATE CORRECTLY, AND PRODUCES A 'YEAR' VARIABLE;
proc sql;
create table alcohol_WBA2 as
select guid, asmnt_question_id, response_text, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id = 6844297730 
;
quit;

*****************************************************************;

*GET DISTINCT FACT_VALUES AND RESPONSE_TEXTS FROM THE 2 DIFFERENT TABLES;
*RECODE NEEDED VARIABLE NAMES AND RESPONSES, SO THAT TABLES CAN BE MERGED TOGETHER;

proc sql;
create table Alcohol_RealAge_reponses as
select distinct fact_value
from alcohol_RealAge2;
quit;


proc sql;
create table Alcohol_WBA_reponses as
select distinct response_text
from alcohol_WBA2;
quit;

*RealAge: fact_values
1, 10, 11, 12, 13, 14, 15plus, 2, 3, 4, 5, 6, 7, 8, 9, none;

*WBA: response_texts
0, 1, 10, 11, 12, 13, 14, 15 or more, 2, 3, 4, 5, 6, 7, 8, 9;

*Apply wba response categories to RealAge
1. None ->0
2. 15plus - > 15 or more
3. fact_id -> asmnt_question_id
4. fact_value -> response_text 
5. valid_from_date -> response_date2;


Data alcohol_RealAge_recode1;
set alcohol_RealAge2;
if fact_value = 'none' then fact_value = '0';
if fact_value = '15plus' then fact_value = '15 or more';
run;


/*
*Did the manipulation work;
*yes, same amount of 15 or more and 0;
proc freq data=shbp.alcohol_RealAge2;
tables fact_value;
run;

proc freq data=shbp.alcohol_RealAge_recode1;
tables fact_value;
run;
*/

Data alcohol_RealAge_recode2 (rename =  (fact_id=asmnt_question_id fact_value=response_text from_date=response_date2)) ;
set alcohol_RealAge_recode1;
run;

proc freq data=alcohol_RealAge_recode2;
table year;
run;

*RECORDS IN THE REALAGE TABLE WITH YEAR GREATHER THAN 2018 ARE DELETED;
*TABLE GOES FROM 132,326 TO 93,134;
Data alcohol_RealAge_recode3;
set alcohol_RealAge_recode2;

if year le 2018;
run;


*****************************************************************;

*MERGE  REALGE AND WBA ALCOHOL DATASETS;
Data alcohol;
set  Alcohol_WBA2 alcohol_RealAge_recode3;
run;


*****************************************************************;

*OBTAIN FIRST AND LAST VALUES FROM THIS MERGED TABLE, 
THEN SORT BY GUID AND RESPONSE_DATE2;

proc sort data=alcohol;
by guid response_date2;
run;


*Alcohol First value;
*N=216,261 RECORDS;
Data alcohol_first;
set alcohol;
by guid;
if first.guid;
run;

*Alcohol Last value;
*N=216,261 RECORDS;
Data alcohol_last;
set alcohol;
by guid;
if last.guid;
run;


*JOIN BOTH FIRST AND LAST ALCOHOL RECORD FILES;
*141,922 RECORDS IN TABLE;
proc sql;
create table Alcohol_first_last as
select 	a.guid, 
		'Alcohol' as item,
		a.asmnt_question_id as Question_fact_id_First,
		a.response_date2 as Date_First,
		a.Year as Year_First,
		a.response_text as Value_First,
		0 as Risk_First,
		b.asmnt_question_id as Question_fact_id_Last,
		b.response_date2 as Date_Last,
		b.Year as Year_Last,
		b.response_text as Value_Last,
		0 as Risk_Last,		
from alcohol_first a inner join alcohol_last b
on a.guid = b.guid
where a.response_date2 <> b.response_date2;
quit;


*DELETE RECORD IN YEAR_FIRST = YEAR_LAST;
*141,922 RECORDS TO 141,439 RECORDS;
Data Alcohol_first_last;
set Alcohol_first_last;

if Year_First = Year_Last then delete;
run;

*****************************************************************;

*BRING DOB AND GENDER INTO TABLE FROM ELIGIBILITY TABLE;

Data Alcohol_first_last2;
set Alcohol_first_last;
Guid_num = Guid*1;
run;


Proc sql;
create table Alcohol_First_Last_Final as
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
from alcohol_first_last2 a inner join shbp2.shbp_eligibility_unique b
on a.Guid_num = b.Guid;
quit;


proc freq data = Alcohol_First_Last_Final;
table gender Gender2 year_first year_last;
run;


*****************************************************************;

*SET RISK DEPENDING ON GENDER AND THE AMOUNT OF ALCOHOL DRINKS BEING CONSUMED;

proc freq data=Alcohol_first_last_final;
table value_first value_last;
run;

*THIS STEP PRODUCES NUMERIC VARIABLES FOR NUMBER OF DRINKS IN EACH TIME PERIOD, AND RISK FLAG BASED ON GENDER AND NUMBER OF DRINKS;
Data alc_working_risk1;
set Alcohol_First_Last_Final;

if Value_First = '1' then drinks_T1 = 1;
else if Value_First = '2' then drinks_T1 = 2;
else if Value_First = '3' then drinks_T1 = 3;
else if Value_First = '4' then drinks_T1 = 4;
else if Value_First = '5' then drinks_T1 = 5;
else if Value_First = '6' then drinks_T1 = 6;
else if Value_First = '7' then drinks_T1 = 7;
else if Value_First = '8' then drinks_T1 = 8;
else if Value_First = '9' then drinks_T1 = 9;
else if Value_First = '10' then drinks_T1 = 10;
else if Value_First = '11' then drinks_T1 = 11;
else if Value_First = '12' then drinks_T1 = 12;
else if Value_First = '13' then drinks_T1 = 13;
else if Value_First = '14' then drinks_T1 = 14;
else if Value_First = '15 or more' then drinks_T1 = 15;
else if Value_First = '0' then drinks_T1 = 0;
else drinks_T1 = .;

if Value_Last = '1' then drinks_T2 = 1;
else if Value_Last = '2' then drinks_T2 = 2;
else if Value_Last = '3' then drinks_T2 = 3;
else if Value_Last = '4' then drinks_T2 = 4;
else if Value_Last = '5' then drinks_T2 = 5;
else if Value_Last = '6' then drinks_T2 = 6;
else if Value_Last = '7' then drinks_T2 = 7;
else if Value_Last = '8' then drinks_T2 = 8;
else if Value_Last = '9' then drinks_T2 = 9;
else if Value_Last = '10' then drinks_T2 = 10;
else if Value_Last = '11' then drinks_T2 = 11;
else if Value_Last = '12' then drinks_T2 = 12;
else if Value_Last = '13' then drinks_T2 = 13;
else if Value_Last = '14' then drinks_T2 = 14;
else if Value_Last = '15 or more' then drinks_T2 = 15;
else if Value_Last = '0' then drinks_T2 = 0;
else drinks_T2 = .;

if Gender2 = 'Female' 
THEN DO;
if drinks_T1 gt 7 then Risk_First = 1;
if drinks_T2 gt 7 then Risk_Last = 1;
END;

if Gender2 = 'Male' 
THEN DO;
if drinks_T1 gt 14 then Risk_First = 1;
if drinks_T2 gt 14 then Risk_Last = 1;
END;

if drinks_T1 = . then Risk_First = .;
if drinks_T2 = . then Risk_Last = .;

Drink_Change = drinks_T2 - drinks_T1;

run;

proc freq data=alc_working_risk1;
table Risk_First Risk_Last;
run;

*****************************************************************;

*THIS STEP DEVELOPS A NEEDED MULTIPLICATON TERM TO USE FOR MEMBERS WHO REDUCE OR ELIMINATE ALCOHOL RISK BY REDUCING NUMBER OF DRINKS;


*RECORD COUNT GOES FROM 141,409 to 141,113;
Data alc_working_risk2 (keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact1 Risk_Last_Updated 
                             year_first year_last Drink_Change AgeGroup year_in_pgm item); 
set alc_working_risk1;


*ONLY RECORDS WITH POPULATED FIRST AND LAST VALUES WILL BE USED IN OBTAINING ASSOCIATED DOLLAR SAVINGS;
if drinks_T1 = . then delete;
if drinks_T2 = . then delete;



Alcohol_Value_per_Risk = 86.0;

*THIS CODE LINE ACCOUNTS FOR MEMBERS WHO ELIMINATE ALCOHOL RISK;
If Risk_First = 1 and Risk_Last = 0 then Impact1 = 1.0;

*THIS CODE ACCOUNTS FOR MEMBERS WITH GO FROM 'NO RISK TO 'AT RISK' REGARDING ALCOHOL;
If Risk_First = 0 and Risk_Last = 1 then Impact1 = -1.0;



*CODING BELOW ACCOUNTS FOR MEMBERS WHO ARE AT RISK AT T1 AND T2, BUT THEIR RISK LEVEL CHANGES;

*I THINK I HAVE A PROBLEM WITH THE EQUATION THAT WE SEE IN THE 'ROI METHODOLOGY' DOCUMENT, I THINK THE DENOMINATOR
SHOULD BE A CONSTANT, AND NOT THIS CALCULATED DENOMINATOR SEEN BELOW;

*FOR FEMALES;
*DECREASE IN RISK;
if Gender2 = 'Female' and Risk_First = 1 and Risk_Last = 1 and Drink_Change lt 0 then DO;
Impact1 = (drinks_T1 - drinks_T2) / (drinks_T1 - 7);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASE IN RISK, OR NO CHANGE IN RISK;
if Gender2 = 'Female' and Risk_First = 1 and Risk_Last = 1 and Drink_Change ge 0 then DO;
Impact1 = (drinks_T1 - drinks_T2) / (15 - drinks_T1);
Risk_Last_Updated = (1 - Impact1);
END;



*FOR MALES;
*DECREASE IN RISK;
if Gender2 = 'Male' and Risk_First = 1 and Risk_Last = 1 and Drink_Change lt 0 then DO;
Impact1 = (drinks_T1 - drinks_T2) / (drinks_T1 - 14);
Risk_Last_Updated = (1 - Impact1);
END;

*INCREASE IN RISK, OR NO CHANGE IN RISK;
if Gender2 = 'Male' and Risk_First = 1 and Risk_Last = 1 and Drink_Change ge 0 then DO;
Impact1 = (drinks_T1 - drinks_T2) / (15 - drinks_T1);
Risk_Last_Updated = (1 - Impact1);
END;



format Alcohol_Value_per_Risk DOLLAR10.2;
format Impact1 Risk_Last_Updated 6.3;

run;

data alc_check;
set alc_working_risk2;

if Gender2 = 'Male' and Risk_First = 1 and Risk_Last = 1;
run;
*****************************************************************;

*THIS ADDED STEP CONNECTS TO PAWEL'S SIMM RISK VALUE COST TABLE, AND ADDS THE RESPECTIVE VALUE OF SIMM RISK
INTO MY SUMMARY TABLE, BASED ON THE YEAR OF MEMBER AND THEIR AGEGROUP;

proc sql;
create table alc_working_risk2_b as 
select a.*, b.cost as SIMM_value_risk
from alc_working_risk2 a left join Shbp_sim_costs_trans_final b
on a.item = b.measured_risks
and a.year_in_pgm = b.Year
and a.agegroup = b.agegroup
;
quit;


*****************************************************************;


*THIS STEP PRODUCES THE DOLLAR AMOUNT ASSOCIATED WITH THE REDUCTION (OR GAIN) IN ALCOHOL RISK;
Data alc_working_risk3;
set alc_working_risk2_b;


*if Impact1 gt 0 then DO;
Alc_Impact_Savings = Impact1*Alcohol_Value_per_Risk;

*THIS IS THE NEW IMPACT SAVINGS, BASED ON THE SIMM COST FROM PAWEL TABLE;
Alc_Impact_Savings2 = Impact1*SIMM_value_risk;

*END;

/*
THIS CODE IS NOT NEEDED HERE, SINC THIS WAS ALREADY TAKEN CARE OF IN STEP BEFORE;

*THIS LINE BELOW TAKES CARE OF MEMBERS WITH NO RISK INITIALLY, AND THEN DEVELOP ALCOHOL RISK;
If Risk_First = 0 and Risk_Last = 1 then DO;
Alc_Impact_Savings = Alcohol_Value_per_Risk * -1;
END;
*/

format Alc_Impact_Savings Alc_Impact_Savings2 DOLLAR10.2;
run;






*************************************************************;

*FINANCIAL RESULTS ASSOCIATED WITH CHANGE IN USE OF ALCOHOL RISK;

proc freq data=alc_working_risk3;
table Alc_Impact_Savings;
title 'SHBP - Frequency of Alcohol Impact'; 
run;

proc means sum data=alc_working_risk3;
var Alc_Impact_Savings Alc_Impact_Savings2 impact1 drinks_T1 drinks_T2;
title 'Final Result for SHBP Alcohol Use Analysis';
run;

proc sort data=alc_working_risk3;
by Year_Last;
run;


proc sql;
title 'Sum of SHBP Alcohol Savings by Last Year of Shown on Record';
select year_last, count(*) as rec_count, sum(Alc_Impact_Savings) as savings_amount format=DOLLAR10.2
from alc_working_risk3
group by year_last
;
quit;


proc sql;
title 'Sum of SHBP Alcohol Savings by FIRST YEAR AND LAST YEAR as Shown on Record';
select year_first, year_last, count(*) as rec_count, sum(Alc_Impact_Savings) as savings_amount format=DOLLAR10.2
from alc_working_risk3
group by year_first, year_last
;
quit;
