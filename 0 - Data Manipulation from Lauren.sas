*Alcohol question;
*RealAge;
data alcohol_RealAge;
set SHBP.Shbp_realage;
keep guid fact_id fact_value valid_from_date;
where fact_id=20000;
run;
*WBA;
data alcohol_WBA;
set shbp.WBA_Guid_workaround_2;
keep guid asmnt_question_id response_text response_date;
where asmnt_question_id=6844297730;
run;


*get distinct fatc_values and reponse_texts;
proc sql;
create table alcohol_RealAge_reponses as
select distinct fact_value
from alcohol_RealAge;
quit;


proc sql;
create table alcohol_WBA_reponses as
select distinct response_text
from alcohol_WBA;
quit;


*RealAge: fact_value
1, 10, 11, 12, 13, 14, 15plus, 2, 3, 4, 5, 6, 7, 8, 9, none;

*WBA: response_text
0, 1, 10, 11, 12, 13, 14, 15 or more, 2, 3, 4, 5, 6, 7, 8, 9;

*Apply wba response categories to RealAge
1. None ->0
2. 15plus - > 15 or more
3. fact_id -> asmnt_question_id
4. fact_value -> response_text 
5. valid_from_date -> response_date;

*1+2;
Data alcohol_RealAge_2;
set alcohol_RealAge;
if fact_value = 'none' then fact_value = '0';
if fact_value = '15plus' then fact_value = '15 or more';
run;
/*
*Did the manipulation work;
*yes, same amount of 15 or more and 0;
proc freq data=shbp.alcohol_RealAge;
tables fact_value;
run;

proc freq data=shbp.alcohol_RealAge_2;
tables fact_value;
run;
*/

*3+4+5;

Data alcohol_RealAge_3; 
rename fact_id=asmnt_question_id fact_value=response_text valid_from_date=response_date ;
set alcohol_RealAge_2;
run;


*Merge Alcohol RealAge and WBA data;
Data alcohol;
set  alcohol_RealAge_3 Alcohol_WBA;
run;




*Frist/last alcohol value
*sort by guid and reponse_date;

proc sort data=alcohol;
by guid response_date;
run;


*Alcohol First value;
*N=229,258;
Data alcohol_first;
set alcohol;
by guid;
if first.guid;
run;

*Alcohol Last value;
*N=229,258;
Data alcohol_last;
set alcohol;
by guid;
if last.guid;
run;

*Join both first and last alcohol Files ;
*147,586 entries;
proc sql;
create table alcohol_first_last as
select 	alcohol_first.guid,
		'Alcohol' as item,
		alcohol_first.asmnt_question_id as question_fact_id_first,
		alcohol_first.response_date as Date_first ,
		0 as Year_first,
		alcohol_first.response_text as value_first,
		0 as Risk_First,
		alcohol_last.asmnt_question_id as question_fact_id_last,
		alcohol_last.response_date as Date_last,
		0 as Year_last,
		alcohol_last.response_text as value_last,
		0 as Risk_Last
from alcohol_first inner join alcohol_last
on alcohol_first.guid = alcohol_last.guid
where alcohol_first.response_date <> alcohol_last.response_date;
quit;


*Populate Year_First and Year last;
Data alcohol_first_last_2;
set alcohol_first_last;
Year_first = substr(put(Date_first, 6.),1,4);
Year_last = substr(put(Date_last, 6.),1,4);
if Year_first = Year_last then delete
run;


*Delete if Year First= Year last;
*147,586 entries before ;
*N=146,904 after;
Data alcohol_first_last_3;
set alcohol_first_last_2;

if Year_first=Year_last then delete;
run;


*Make Guid numeric for next step, becuase case unfortunately does not work in sas;
Data alcohol_first_last_4;
set alcohol_first_last_3;
Guid_2=Guid*1;
run;



* Attach age and gender to fle;
*N=146,904 Before;
*N=146,874 after;
Proc sql;
create table alcohol_first_last_5 as
select a.Guid, b.DOB, b.Gender, a.item, a.question_fact_id_first, a.Date_first, a.Year_first, a.value_first, a.Risk_first, a.question_fact_id_last, a.Date_last, a.Year_last, a.value_last, a.Risk_last
from alcohol_first_last_4 a
inner join shbp.shbp_eligibility_unique b
on a.Guid_2 =b.Guid;
quit;

*next steps:
-remove 2019 values from RA data
-make gender  variable 2=Male and 3=Female
-create age out of DOB (last response?)
-make risk 0 or 1 depending on gender thershold
-calculate net risk change
	-new risk
	-fully mitigated
	-improvement (but stil at risk)
	-woresening (still at risk);









LIBNAME shbp 'C:/Users/lauren.duke/OneDrive - Sharecare, Inc/dukel';

proc sort data=work.shbpratm; by secure_ID; quit;
proc transpose data=work.shbpratm out=wide prefix=_;
	by secure_id;
	id fact_id;
	var fact_value;
run; 

Data shbp.ratm;
set work.shbpratm;

data shbp.wba2017;
set wba;
run;

data shbp.realage;
set shbp.ratm;
keep secure_id _19933 _10002 _10003 _19998 _20000 _10020 _10019 _10018 _10017 _20463 _20462 _20008 _20513 _19988 
_19992 _19990 _20508 _258 _18500 _20511 _10099 _10060 _20510;
run;

data shbp.realage1;
set shbp.realage;

if _19933 = '0Worst' then ladder = 0;
else if _19933 = 1 then ladder = 1;
else if _19933 = 2 then ladder = 2;
else if _19933 = 3 then ladder = 3;
else if _19933 = 4 then ladder = 4;
else if _19933 = 5 then ladder = 5;
else if _19933 = 6 then ladder = 6;
else if _19933 = 7 then ladder = 7;
else if _19933 = 8 then ladder = 8;
else if _19933 = 9 then ladder = 9;
else if _19933 = '10Best' then ladder = 10;
else if _19933 = 'dontKnow' then ladder = .;
else ladder = .;

if ladder >= 7 then ladder_risk = 0;
else if ladder < 7 then ladder_risk = 1;
else ladder = .;

if _20510 = 'notSatisfied' then life_satisfaction = 9;
else if _20510 = 'partly' then life_satisfaction = 3;
else if _20510 = 'mostly' then life_satisfaction = 2;
else if _20510 = 'completely' then life_satisfaction = 1;
else life_satisfaction = .;

if _10060 = 0 then suffered_loss =3;
else if _10060 = 1 then suffered_loss = 6;
else if _10060 = 2 then suffered_loss = 9;
else suffered_loss = .;

if _10099 = 4 then hours_sleep = 4;
else if _10099 = 5 then hours_sleep = 4;
else if _10099 = 6 then hours_sleep = 4;
else if _10099 = 7 then hours_sleep = 2;
else if _10099 = 8 then hours_sleep = 2;
else if _10099 = 9 then hours_sleep = 4;
else if _10099 = '9plus' then hours_sleep = 4;
else if _10099 = 'lessThan4' then hours_sleep = 4;
else hours_sleep = .;

if _20511 = 'weakerAverage' then social_ties = 8;
else if _20511 = 'average' then social_ties = 5;
else if _20511 = 'aboveAverage' then social_ties = 2;
else if _20511 = 'Not Sure' then social_ties = 5;
else social_ties = .;

/*answer choices do not match WBA answer choices*/
if _18500 = 'divorced' then marital_status = 4;
else if _18500 = 'widowed' then marital_status = 5;
else if _18500 = 'married' then marital_status = 1;
else if _18500 = 'neverMarried' then marital_status = 2;

if _20508 = 'poor' then self_rated_health = 5;
else if _20508 = 'fair' then self_rated_health = 3;
else if _20508 = 'good' then self_rated_health = 2;
else if _20508 = 'veryGood' then self_rated_health = 1;
else if _20508 = 'excellent' then self_rated_health = 1;
else self_rated_health = .;

/*composite risk score for stress: marital status, personal loss, life satisfation,
perception of health, hours of sleep, social ties*/
if sum(marital_status+social_ties+hours_sleep+suffered_loss+life_satisfaction+
self_rated_health) >= 18 then stress_risk = 1;
else if sum(marital_status+social_ties+hours_sleep+suffered_loss+life_satisfaction+
self_rated_health) < 18 then stress_risk = 0;
else if marital_status = . or social_ties=. or hours_sleep=. or suffered_loss=. 
or life_satisfaction=. or self_rated_health=. then stress_risk=.;

if _19990 = 'yes' then exp_stress = 0;
else if _19990 = 'no' then exp_stress = 1;
else exp_stress = .;

if _19992 = 'yes' then exp_worry = 0;
else if _19992 = 'no' then exp_worry = 1;
else exp_worry = .;

if _19988 = 'never' then use_drugs_relax = 4;
else if _19988 = 'rarely' then use_drugs_relax = 3;
else if _19988 = 'sometimes' then use_drugs_relax = 2;
else if _19988 = 'almostDaily' then use_drugs_relax = 1;
else use_drugs_relax = .;

if use_drugs_relax =3 then drugs_risk = 0;
else if use_drugs_relax <= 2 then drugs_risk = 1;
else drugs_risk = .;

if _20513 = '16Plus' then days_missed = '16+';
else if _20513 = '11to15' then days_missed = '11-15';
else if _20513 = '6to10' then days_missed = '6-10';
else if _20513 = '3to5' then days_missed = '3-5';
else if _20513 = '1to2' then days_missed = '1-2';
else if _20513 = 'none' then days_missed = '0';
else days_missed = .;

if days_missed = '16+' then illness_risk = 1;
else if days_missed = '11-15' then illness_risk = 1;
else if days_missed = '6-10' then illness_risk = 1;
else if days_missed = '3-5' then illness_risk = 0;
else if days_missed = '1-2' then illness_risk = 0;
else if days_missed = '0' then illness_risk = 0;
else illness_risk = .;

if _20008 = 'yes' then smoke = 1;
else if _20008 = 'no' then smoke = 0;
else smoke = .;

/*fact_id_20514 (exercise) does not exist in RAT data*/

if _20000 = 1 then drinks_week = 1;
else if _20000 = 2 then drinks_week = 2;
else if _20000 = 3 then drinks_week = 3;
else if _20000 = 4 then drinks_week = 4;
else if _20000 = 5 then drinks_week = 5;
else if _20000 = 6 then drinks_week = 6;
else if _20000 = 7 then drinks_week = 7;
else if _20000 = 8 then drinks_week = 8;
else if _20000 = 9 then drinks_week = 9;
else if _20000 = 10 then drinks_week = 10;
else if _20000 = 11 then drinks_week = 11;
else if _20000 = 12 then drinks_week = 12;
else if _20000 = 13 then drinks_week = 13;
else if _20000 = 14 then drinks_week = 14;
else if _20000 = '15plus' then drinks_week = 15;
else if _20000 = 'none' then drinks_week = 0;
else drinks_week = .;

if drinks_week > 14 and gender = 'male' then drink_risk = 1;
else if drinks_week >9 and gender = 'female' then drink_risk = 1;
else drinks_risk = 0;

if _19998 = 1 then fruits_veg = 1;
else if _19998 = 2 then fruits_veg = 2;
else if _19998 = 3 then fruits_veg = 3;
else if _19998 = 4 then fruits_veg = 4;
else if _19998 = 5 then fruits_veg = 5;
else if _19998 = 6 then fruits_veg = 6;
else if _19998 = 7 then fruits_veg = 7;
else if _19998 = 'none' then fruits_veg = 0;
else if _19998 = 'dontKnow' then fruits_veg = .;
else fruits_veg = .;

if fruits_veg < 5 then fruit_risk = 1;
else if fruits_veg >=5 then fruit_risk = 0;
else fruit_risk = .;

run;

/*data shbp.realage1;
set shbp.realage1;
drop _19933 _10002 _10003 _19998 _20000 _10020 _10019 _10018 _10017 _20463 _20462 _20008 _20513 _19988 
_19992 _19990 _20508 _258 _18500 _20511 _10099 _10060 _20510;
run;*/

data shbp.wba1;
set shbp.wba2017;

if ladder = '0 - Worst' then ladder = 0;
else if ladder = 1 then ladder = 1;
else if ladder = 2 then ladder = 2;
else if ladder = 3 then ladder = 3;
else if ladder = 4 then ladder = 4;
else if ladder = 5 then ladder = 5;
else if ladder = 6 then ladder = 6;
else if ladder = 7 then ladder = 7;
else if ladder = 8 then ladder = 8;
else if ladder = 9 then ladder = 9;
else if ladder = '10 - Best' then ladder = 10;
else if ladder = 'Don' then ladder = .;
else ladder = .;

if ladder >= 7 then ladder_risk = 0;
else if ladder < 7 then ladder_risk = 1;
else ladder = .;

if life_satisfaction = 'Not satisfied' then life_satisfaction = 9;
else if life_satisfaction = 'Partly satisfied' then life_satisfaction = 3;
else if life_satisfaction = 'Mostly satisfied' then life_satisfaction = 2;
else if life_satisfaction = 'Completely satisfied' then life_satisfaction = 1;
else life_satisfaction = .;

if suffered_loss = 'No' then suffered_loss =3;
else if suffered_loss = 'Yes, one serious loss' then suffered_loss = 6;
else if suffered_loss = 'Yes, two or more seriou' then suffered_loss = 9;
else suffered_loss = .;

if hours_sleep = '4 hours' then hours_sleep = 4;
else if hours_sleep = '5 hours' then hours_sleep = 4;
else if hours_sleep = '6 hours' then hours_sleep = 4;
else if hours_sleep = '7 hours' then hours_sleep = 2;
else if hours_sleep = '8 hours' then hours_sleep = 2;
else if hours_sleep = '9 hours' then hours_sleep = 4;
else if hours_sleep = '9 or more' then hours_sleep = 4;
else if hours_sleep = 'Less than' then hours_sleep = 4;
else hours_sleep = .;

if social_ties = 'Weaker than average' then social_ties = 8;
else if social_ties = 'About average' then social_ties = 5;
else if social_ties = 'Very strong' then social_ties = 2;
else if social_ties = 'Not Sure' then social_ties = 5;
else social_ties = .;

/*way more answer options available in original WBA question*/
if marital_status = 'Divorced' then marital_status = 4;
else if marital_status = 'Widowed' then marital_status = 5;
else if marital_status = 'Married' then marital_status = 1;
else if marital_status = 'Single/Never been marr' then marital_status = 2;
else if marital_status = 'Separated' then marital_status = 4;
else if marital_status = 'Domestic Partner' then marital_status = 3;
else if marital_status = 'Prefer not to answer' then marital_status = 2;
else marital_status = 2;

if self_rated_health = 'Poor' then self_rated_health = 5;
else if self_rated_health = 'Fair' then self_rated_health = 3;
else if self_rated_health = 'Good' then self_rated_health = 2;
else if self_rated_health = 'Very Good' then self_rated_health = 1;
else if self_rated_health = 'Excellent' then self_rated_health = 1;
else self_rated_health = .;

/*composite risk score for stress: marital status, personal loss, life satisfation,
perception of health, hours of sleep, social ties*/
if sum(marital_status+social_ties+hours_sleep+suffered_loss+life_satisfaction+
self_rated_health) >= 18 then stress_risk = 1;
else if sum(marital_status+social_ties+hours_sleep+suffered_loss+life_satisfaction+
self_rated_health) < 18 then stress_risk = 0;
else if marital_status = . or social_ties=. or hours_sleep=. or suffered_loss=. 
or life_satisfaction=. or self_rated_health=. then stress_risk=.;

if exp_stress = 'Yes' then exp_stress = 0;
else if exp_stress = 'No' then exp_stress = 1;
else exp_stress = .;

if exp_worry = 'Yes' then exp_worry = 0;
else if exp_worry = 'No' then exp_worry = 1;
else exp_worry = .;

/*rarely and never answers are combined in WBA scoring*/
if use_drugs_relax = 'Rarely or never' then use_drugs_relax = 3;
else if use_drugs_relax = 'Sometimes' then use_drugs_relax = 2;
else if use_drugs_relax = 'Almost every day' then use_drugs_relax = 1;
else use_drugs_relax = .;

if use_drugs_relax =3 then drugs_risk = 0;
else if use_drugs_relax <= 2 then drugs_risk = 1;
else drugs_risk = .;

if days_missed = '16 days or m' then days_missed = '16+';
else if days_missed = '11 - 15 days' then days_missed = '11-15';
else if days_missed = '6 - 10 days' then days_missed = '6-10';
else if days_missed = '3 - 5 days' then days_missed = '3-5';
else if days_missed = '1 - 2 days' then days_missed = '1-2';
else if days_missed = '0 days' then days_missed = '0';
else days_missed = .;

if days_missed = '16+' then illness_risk = 1;
else if days_missed = '11-15' then illness_risk = 1;
else if days_missed = '6-10' then illness_risk = 1;
else if days_missed = '3-5' then illness_risk = 0;
else if days_missed = '1-2' then illness_risk = 0;
else if days_missed = '0' then illness_risk = 0;
else illness_risk = .;

if smoke = 'Yes' then smoke = 1;
else if smoke = 'No' then smoke = 0;
else smoke = .;

if exercise = 'On average, less than 1 time per week' then exercise_risk = 1;
else if exercise = 'Moderate: 5 or more times per week' then exercise_risk = 1;
else if exercise = 'Moderate: 1-4 times per week' then exercise_risk = 1;
else if exercise = 'Vigorous: 1-2 times per week' then exercise_risk = 1;
else if exercise = 'Vigorous: 3 or more times per week' then exercise_risk = 1;
else if exercise = 'I do not exercise regularly' then exercise_risk = 1;

if drinks_week = 1 then drinks_week = 1;
else if drinks_week = 2 then drinks_week = 2;
else if drinks_week = 3 then drinks_week = 3;
else if drinks_week = 4 then drinks_week = 4;
else if drinks_week = 5 then drinks_week = 5;
else if drinks_week = 6 then drinks_week = 6;
else if drinks_week = 7 then drinks_week = 7;
else if drinks_week = 8 then drinks_week = 8;
else if drinks_week = 9 then drinks_week = 9;
else if drinks_week = 10 then drinks_week = 10;
else if drinks_week = 11 then drinks_week = 11;
else if drinks_week = 12 then drinks_week = 12;
else if drinks_week = 13 then drinks_week = 13;
else if drinks_week = 14 then drinks_week = 14;
else if drinks_week = '15 or more' then drinks_week = 15;
else if drinks_week = 0 then drinks_week = 0;
else drinks_week = .;

if drinks_week > 14 and gender = 'male' then drink_risk = 1;
else if drinks_week >9 and gender = 'female' then drink_risk = 1;
else drinks_risk = 0;

if fruits_veg = 1 then fruits_veg = 1;
else if fruits_veg = 2 then fruits_veg = 2;
else if fruits_veg = 3 then fruits_veg = 3;
else if fruits_veg = 4 then fruits_veg = 4;
else if fruits_veg = 5 then fruits_veg = 5;
else if fruits_veg = 6 then fruits_veg = 6;
else if fruits_veg = 7 then fruits_veg = 7;
else if fruits_veg = 0 then fruits_veg = 0;
else if fruits_veg = 'Don' then fruits_veg = .;
else fruits_veg = .;

if fruits_veg < 5 then fruit_risk = 1;
else if fruits_veg >=5 then fruit_risk = 0;
else fruit_risk = .;

run;


data shbp.realage1;
set shbp.realage1;
survey_completion_date=.;
run;

data shbp.realage1;
set shbp.realage1;
if survey_completion_date = . then survey_completion_date = '2018';
run;

data shbp.wba2;
set shbp.wba1;
char_survey_completion_date = input(survey_completion_date, 4.);
char_ladder = input(ladder, 11.);
char_life_satisfaction = input(life_satisfaction, 22.);
char_suffered_loss = input(suffered_loss, 23.);
char_hours_sleep = input(hours_sleep, 9.);
char_social_ties = input(social_ties, 21.);
char_self_rated_health = input(self_rated_health, 11.);
char_exp_stress = input(exp_stress, 7.);
char_exp_worry = input(exp_worry, 7.);
char_use_drugs_relax = input(use_drugs_relax, 18.);
char_smoke = input(smoke, 7.);
char_drinks_week =input(drinks_week, 7.);
char_fruits_veg = input(fruits_veg, 7.);
char_marital_status = input(marital_status, 7.);
drop survey_completion_date;
drop ladder;
drop life_satisfaction;
drop suffered_loss;
drop hours_sleep;
drop social_ties;
drop self_rated_health;
drop exp_stress;
drop exp_worry;
drop use_drugs_relax;
drop smoke;
drop drinks_week;
drop fruits_veg;
drop marital_status;
rename char_survey_completion_date=survey_completion_date;
rename char_ladder = ladder;
rename char_life_satisfaction=life_satisfaction;
rename char_suffered_loss = suffered_loss;
rename char_hours_sleep = hours_sleep;
rename char_social_ties = social_ties;
rename char_self_rated_health =self_rated_health;
rename char_exp_stress = exp_stress;
rename char_exp_worry = exp_worry;
rename char_use_drugs_relax = use_drugs_relax;
rename char_smoke = smoke;
rename char_drinks_week = drinks_week;
rename char_fruits_veg = fruits_veg;
rename char_marital_status = marital_status;
run;

data shbp.combined;
   set shbp.wba2 shbp.realage1;
run;

proc sort data=shbp.combined;
by survey_completion_date;
run;

proc freq data=shbp.combined;
table ladder life_satisfaction suffered_loss hours_sleep social_ties self_rated_health
exp_stress exp_worry use_drugs_relax smoke drinks_week fruits_veg ;
by survey_completion_date;
run;

/*Frequencies of risks for 2017 and 2018*/

proc freq data=shbp.combined;
tables ladder_risk stress_risk exp_stress exp_worry drugs_risk illness_risk 
smoke drinks_risk fruit_risk;
by survey_completion_date;
run;




proc sort data=shbp.Wba2017;
by survey_completion_date;
run;

proc freq data=shbp.Wba2017;
table ladder life_satisfaction suffered_loss hours_sleep social_ties self_rated_health
exp_stress exp_worry use_drugs_relax smoke drinks_week fruits_veg;
run;

proc freq data=shbp.ratm;
table _19933 _10002 _10003 _19998 _20000 _10020 _10019 _10018 _10017 _20463 _20462 _20008;
run;

proc freq data=shbp.Wba2017;
table exercise;
run;
