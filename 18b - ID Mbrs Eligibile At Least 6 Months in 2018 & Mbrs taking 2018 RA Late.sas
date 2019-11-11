
*USE AVAILABLE ELIGIBILITY TABLES TO DETERMINE MEMBERS WHO HAVE AT LEAST 6 MONTHS OF ELIGIBILITY IN 2018 YEAR;


*4,819,571 RECORDS;
proc sql;
select count(*) from Shbp2.Shbp_eligibility;
quit;
*791,783 RECORDS;
proc sql;
select count(*) from Shbp2.Shbp_eligibility_unique;
quit;



proc sql;
create table Members_elig1 as
select distinct guid, EligibilityStartDate, EligibilityEndDate, 
       input(EligibilityStartDate, anydtdte24.) as EligibilityStartDate2 format=mmddyy10.,
	   input(EligibilityEndDate, anydtdte24.) as EligibilityEndDate2 format=mmddyy10.,
	   year(calculated EligibilityEndDate2) as year_end
from SHBP2.Shbp_eligibility
order by guid, EligibilityEndDate2
;
quit;


Data Members_elig2;
set Members_elig1;

EligibilityEndDate3 = EligibilityEndDate2;

if EligibilityEndDate3 = '31Dec9999'D then EligibilityEndDate3 = '11Oct2019'D;
year_end3 = year(EligibilityEndDate3);

format EligibilityEndDate3 mmddyy10.;
run;


*791,783 DISTINCT MEMBERS IN THIS ELIGIBILITY DATA;
proc sql;
select count(distinct Guid) as distinct_members_shbp
from Members_elig2
;
quit;


*NOT GOING TO USE THIS NOW;
*791,783 RECORDS;
proc sql;
create table Members_elig3 as
select distinct Guid, min(EligibilityStartDate2) as min_elig_date format=mmddyy10., 
                max(EligibilityEndDate3) as max_elig_date format=mmddyy10.
from Members_elig2
group by Guid
;
quit;


*****************************************************************************************************;
*CREATE TABLE FOR ELIGIBILITY IN 2018 YEAR;

proc sql;
create table members_shbp_elig_2018 as 
select distinct Guid, put(Guid, 15.) as Guid_char,
                0 as Jan_18, 0 as Feb_18, 0 as Mar_18, 0 as Apr_18, 0 as May_18, 0 as Jun_18,
                0 as Jul_18, 0 as Aug_18, 0 as Sep_18, 0 as Oct_18, 0 as Nov_18, 0 as Dec_18
from Members_elig2
;
quit;


proc sql;
create index Guid on members_shbp_elig_2018(Guid);
create index Guid on Members_elig2(Guid);
quit;

*JAN FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Jan_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01JAN2018'd
                 and b.EligibilityEndDate3 ge '31JAN2018'd)
;
quit; 

*FEB FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Feb_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01FEB2018'd
                 and b.EligibilityEndDate3 ge '28FEB2018'd)
;
quit; 

*MARCH FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Mar_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01MAR2018'd
                 and b.EligibilityEndDate3 ge '31MAR2018'd)
;
quit; 


*APRIL FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Apr_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01APR2018'd
                 and b.EligibilityEndDate3 ge '30APR2018'd)
;
quit; 
        

*MAY FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set May_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01MAY2018'd
                 and b.EligibilityEndDate3 ge '31MAY2018'd)
;
quit; 
        
*JUNE FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Jun_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01JUN2018'd
                 and b.EligibilityEndDate3 ge '30JUN2018'd)
;
quit; 
        
*JULY FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Jul_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01JUL2018'd
                 and b.EligibilityEndDate3 ge '31JUL2018'd)
;
quit; 


*AUG FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Aug_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01AUG2018'd
                 and b.EligibilityEndDate3 ge '31AUG2018'd)
;
quit; 
        
*SEPT FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Sep_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01SEP2018'd
                 and b.EligibilityEndDate3 ge '30SEP2018'd)
;
quit; 
        
*OCT FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Oct_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01OCT2018'd
                 and b.EligibilityEndDate3 ge '31OCT2018'd)
;
quit; 
        
*NOV FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Nov_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01NOV2018'd
                 and b.EligibilityEndDate3 ge '30NOV2018'd)
;
quit; 
        
*DEC FLAG UPDATE;
proc sql;
update members_shbp_elig_2018 a
set Dec_18 = 1
where a.Guid in (select distinct b.Guid 
                 from Members_elig2 b
				 where b.EligibilityStartDate2 le '01DEC2018'd
                 and b.EligibilityEndDate3 ge '31DEC2018'd)
;
quit; 
        

*708,458 MEMBERS WITH 12 MONTHS ELIGIBILITY IN 2018, 
723,045 MEMBERS WITH 6 OR MORE MONTHS ELIGIBILITY IN 2018;
Data members_shbp_elig_2018;
set members_shbp_elig_2018;

total_months_elig_2018 = Jan_18 + Feb_18 + Mar_18 + Apr_18 + May_18 + Jun_18 +
                         Jul_18 + Aug_18 + Sep_18 + Oct_18 + Nov_18 + Dec_18;

proc sort;
by descending total_months_elig_2018;
run;

*723,045 MEMBERS WITH 6 OR MORE MONTHS ELIG IN 2018;
proc sql;
select count(distinct guid) as members
from members_shbp_elig_2018
where total_months_elig_2018 ge 6
;
quit;

proc sql;
create table members_shbp_elig_2018_6plus as
select guid
from members_shbp_elig_2018
where total_months_elig_2018 ge 6
;
quit;

*CREATE A GUIDE VARIABLE IN A 'CHRACTER' FORMAT;
Data members_shbp_elig_2018_6plus;
set members_shbp_elig_2018_6plus;

Guid_char = strip(put(guid,15.));
run;

     

**************************************************************************************************************;
**************************************************************************************************************;
**************************************************************************************************************;

*IDENTIFY MEMBERS WHO TOOK THEIR 2018 SURVEY IN THE LASTD 3 MONTHS OF THE YEAR, THESE MEMBERS
WILL BE EXCLUDED IN THE IMPUTATION WORK-UP;

*THESE QUERIES BELOW USE THE INDIVIDUAL REALAGE TABLES PRODUCED IN PROGRAMS USED BEFORE,
FOR THE DIFFERENT HEALTH BEHAVIORS USED IN THIS ANALYSIS;

*7651;
proc sql;
select count (distinct guid)
from Meds_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*7249;
proc sql;
select count (distinct guid)
from Alcohol_realage2
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*8241;
proc sql;
select count (distinct guid)
from Activity_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*8713;
proc sql;
select count (distinct guid)
from Percept_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*8621;
proc sql;
select count (distinct guid)
from Life_realage2
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*7071;
proc sql;
select count (distinct guid)
from Smoke_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;

*7382;
proc sql;
select count (distinct guid)
from Stress_ra_quest
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;


*THIS MAKES A TABLE OF 9,196 DISTINCT MEMBERS WHOSE REALAGE SURVEY TAKEN IN 2018
IS IN LAST 3 MONTHS OF THE YEAR, AND WILL BE EXCLUDED FROM THE COUNT OF MEMBERS FOR IMPUTATION PURPOSES;
proc sql;
create table members_shbp_survey18_late as
select distinct guid
from Meds_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Alcohol_realage2
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Activity_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Percept_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Life_realage2
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Smoke_realage
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
UNION 
select distinct guid
from Stress_ra_quest
where year = 2018
and from_date between '01OCT2018'd and '31OCT2018'd
;
quit;



