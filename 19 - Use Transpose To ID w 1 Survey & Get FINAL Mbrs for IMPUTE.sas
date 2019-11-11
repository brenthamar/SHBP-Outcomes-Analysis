
*WBA TRANSPOSE - TO GET ONE RECORD PER MEMBERS FOR EACH YEAR THEY TOOK WBA SURVEY;


proc sql;
create table Member_WBA_Surveys_imput0 as
select distinct guid,response_text, asmnt_question_id, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id in (6844297730, 6844297350, 6844297000, 6844297240, 6844297340, 6844297710, 6844297640,
                            6844297230, 6844297200, 6844297210, 6844297220) 
order by guid, response_date desc, year
;
quit;


proc sql;
create table Member_WBA_Surveys_imput1 as
select distinct guid,response_text, asmnt_question_id,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
where asmnt_question_id in (6844297730, 6844297350, 6844297000, 6844297240, 6844297340, 6844297710, 6844297640,
                            6844297230, 6844297200, 6844297000, 6844297210, 6844297220) 
order by guid, response_date2, year
;
quit;


*GET RID OF MULTIPLE RECORDS OF SOME MEMBERS;
proc sort nodupkey data=Member_WBA_Surveys_imput0 out=Member_WBA_Surveys_imput0_dedup;
by guid asmnt_question_id response_date2 year;
run;


*SORT PROPERLY, SO CAN USE THE TABLE IN THE TRANSPOSE;
proc sort data=Member_WBA_Surveys_imput0_dedup;
by guid response_date2 year;
run;


*THIS TRANSPOSE PRODUCES A FINAL WBA TABLE WITH 1 RECORD FOR A MEMBER FOR EACH YEAR TAKEN;
proc transpose data=Member_WBA_Surveys_imput0_dedup out=Member_WBA_Surveys_imput0_dedupT;
by guid response_date2 year;
ID asmnt_question_id;
var response_text;
run;


*69,900 MEMBERS SHOWING 1 WBA SURVEY DISTINCT DATE;
proc sql;
create table Member_WBA_Surveys_IMPUT_3 as 
select Guid, count(distinct response_date2) as survey_count
from Member_WBA_Surveys_imput0_dedupT
group by Guid
order by survey_count
;
quit;


*TABLE OF THESE 69,900 DISTINCT MEMBERS SHOWN ABOVE;
proc sql;
create table Member_WBA_Surveys_IMPUT_4 as 
select Guid, count(distinct response_date2) as survey_count
from Member_WBA_Surveys_imput0_dedupT
group by Guid
HAVING survey_count = 1
order by survey_count
;
quit;

******************************************************************************************************************;
******************************************************************************************************************;
******************************************************************************************************************;

*REALAGE;

proc sql;
create table Member_RA_Surveys_imput0 as
select customer, guid, fact_id, fact_value,
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where fact_id IN (20000, 20513, 20510, 19988, 20508, 20514, 18500, 10060, 10099, 20511, 20008)
and calculated year = 2018
order by guid, from_date desc, year 
;
quit;


proc sql;
create table Member_RA_Surveys1 as
select distinct customer, guid, 
       input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
	   year(calculated from_date) as year
from SHBP2.Shbp_realage
where calculated year = 2018
order by guid, from_date 
;
quit;


*GET RID OF MULTIPLE RECORDS OF SOME MEMBERS;
proc sort nodupkey data=Member_RA_Surveys_imput0 out=Member_RA_Surveys_imput0_dedup;
by guid fact_id from_date year;
run;


*SORT PROPERLY, SO CAN USE THE TABLE IN THE TRANSPOSE;
proc sort data=Member_RA_Surveys_imput0_dedup;
by guid from_date year;
run;


*THIS TRANSPOSE PRODUCES A FINAL WBA TABLE WITH 1 RECORD FOR A MEMBER FOR EACH YEAR TAKEN;
proc transpose data=Member_RA_Surveys_imput0_dedup out=Member_RA_Surveys_imput0_dedupT;
by guid from_date year;
ID fact_id;
var fact_value;
run;


*138,512 RECORDS IN THIS TABLE;
Data Members_RA_Surveys_imput_2018;
set Member_RA_Surveys_imput0_dedupT; 

if year = 2018;
run;


*QUESTIONABLE - 60,248 DISTINCT MEMBERS SHOWING 1 REALAGE SURVEY DISTINCT DATE IN THE 2018 YEAR;
proc sql;
create table Members_RA_Surveys_imput_2018_b as 
select Guid, count(distinct from_date) as survey_count
from Members_RA_Surveys_imput_2018
where year = 2018
group by Guid
order by survey_count
;
quit;


*TABLE OF THESE 46,133 DISTINCT MEMBERS - THIS RA TABLE COMES FROM INITIAL RUNS ON PGM #18
REVIEW OF THE TRANSPOSED TABLE ABOVE SEEMS TO SHOW SOME POSSIBLE DATA ISSUE WITH SOME MEMBERS WHERE THEIR RECORD WAS SPLIT INTO 2 RECORDS;
proc sql;
create table Member_RA_Surveys_IMPUT3 as 
select Guid, count(distinct from_date) as survey_count
from Member_RA_Surveys1
group by Guid
HAVING survey_count = 1
order by survey_count
;
quit;


******************************************************************************************************************;
******************************************************************************************************************;


*60,431 DISTINCT MEMBERS WHO HAVE 1 PRIOR WBA SURVEY, AND NO RA SURVEY FROM 2018;
proc sql;
select count(distinct Guid) as member_count
from Member_WBA_Surveys_IMPUT_4
where Guid not in (select distinct Guid from Members_RA_Surveys_imput_2018)
;
quit;


*40,079 DISTINCT MEMBERS WHO HAVE 1 REALAGE SURVEY FROM 2018 YEAR AND NO RECORD OF A PREVIOUS WBA SURVEY;
proc sql;
select count(distinct Guid) as member_count
from Member_RA_Surveys_IMPUT3
where Guid not in (select distinct Guid from Member_WBA_Surveys_IMPUT_4)
;
quit;


*100,510 DISTINCT MEMBERS SHBP MEMBERS WHO HAVE JUST ONE DOCUMENTED SURVEY IN COMBINED WBA AND RA SURVEY 2018 DATA;
proc sql;
create table SHBP_members_one_survey_f_IMP1 as
select distinct Guid
from Member_WBA_Surveys_IMPUT_4
where Guid not in (select distinct Guid from Members_RA_Surveys_imput_2018)
UNION 
select distinct Guid
from Member_RA_Surveys_IMPUT3
where Guid not in (select distinct Guid from Member_WBA_Surveys_IMPUT_4)
;
quit;



*****************************************************************************************************************;



*TAKE OUT MEMBERS THAT HAVE TAKEN THE 2018 SURVEY IN THE LAST 3 MONTHS OF YEAR,
AND MAKE SURE THAT MEMBERS HAVE AT LEAST 6 MONTHS OF ELIGIBILITY IN 2018;

*94,188 MEMBERS - POSSIBLE FINAL TABLE OF MEMBERS FOR USE IN IMPUTATION EXERCISE;
proc sql;
create table SHBP_members_for_impute_FINAL as
select *
from SHBP_members_one_survey_f_IMP1
where guid in (select Guid_char from Members_shbp_elig_2018_6plus)
and guid not in (select guid from members_shbp_survey18_late)
;
quit;



*USING JUST THE COUNT OF MEMBERS FROM 2018 THAT HAVE JUST 1 REALAGE SURVEY, AND NO RECORD
OF A PREVIOUS WBA SURVEY

*35,217 DISTINCT MEMBERS - POSSIBLE FINAL NUMBER OF MEMBERS FOR USE IN IMPUTATION EXERCISE;
proc sql;
select count(distinct Guid) as member_count
from Member_RA_Surveys_IMPUT3
where Guid not in (select distinct Guid from Member_WBA_Surveys_IMPUT_4)
AND guid in (select Guid_char from Members_shbp_elig_2018_6plus)
AND guid not in (select guid from members_shbp_survey18_late)
;
quit;


