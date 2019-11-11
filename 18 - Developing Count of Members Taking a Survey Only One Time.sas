
*IDNTIFYING A COUNT OF MEMBERS WHO TAKE A SURVEY (WBA OR REALAGE) ONLY ONE TIME;


*WBA;

proc sql;
create table Member_WBA_Surveys1 as
select distinct guid, response_date,
       input(response_date, anydtdte24.) as response_date2 format=mmddyy10.,
	   year(calculated response_date2) as year
from SHBP2.WBA_Guid_workaround_2
order by guid, response_date2
;
quit;

*YEARS SHOWN FR0M 2012 TO 2018, FEW RECORDS IN 2012, 2013 & 2018;
proc freq data=Member_WBA_Surveys1;
table year;
run;

*69,900 MEMBERS SHOWING 1 WBA SURVEY DISTINCT DATE;
proc sql;
create table Member_WBA_Surveys2 as 
select Guid, count(distinct response_date2) as survey_count
from Member_WBA_Surveys1
group by Guid
order by survey_count
;
quit;

*TABLE OF THESE 69,900 DISTINCT MEMBERS SHOWN ABOVE;
proc sql;
create table Member_WBA_Surveys3 as 
select Guid, count(distinct response_date2) as survey_count
from Member_WBA_Surveys1
group by Guid
HAVING survey_count = 1
order by survey_count
;
quit;

****************************************************************************************************************;
****************************************************************************************************************;

*REALAGE;
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

*YEAR SHOWN IS JUST 2018 - SINCE YEAR IS LIMITED ABOVE;
proc freq data=Member_RA_Surveys1;
table year;
run;


*46,133 DISTINCT MEMBERS SHOWING 1 REALAGE SURVEY DISTINCT DATE IN THE 2018 YEAR;
proc sql;
create table Member_RA_Surveys2 as 
select Guid, count(distinct from_date) as survey_count
from Member_RA_Surveys1
where year = 2018
group by Guid
order by survey_count
;
quit;

*TABLE OF THESE 46,133 DISTINCT MEMBERS SHOWN ABOVE;
proc sql;
create table Member_RA_Surveys3 as 
select Guid, count(distinct from_date) as survey_count
from Member_RA_Surveys1
group by Guid
HAVING survey_count = 1
order by survey_count
;
quit;

****************************************************************************************************************;
****************************************************************************************************************;

*THIS CODE BELOW USED TO IDENTIFY THE DISTINCT MEMBERS WITH JUST 1 SURVEY COMPLETED, FOR 2018 OR BEFORE;


*63,846 DISTINCT MEMBERS WHO HAVE 1 WBA SURVEY, AND NO RA SURVEY FROM 2018;
proc sql;
select count(distinct Guid) as member_count
from Member_wba_surveys3
where Guid not in (select distinct Guid from Member_RA_Surveys3)
;
quit;


*40,079 DISTINCT MEMBERS WHO HAVE 1 REALAGE SURVEY FROM 2018 YEAR AND NO RECORD OF A PREVIOUS WBA SURVEY;
proc sql;
select count(distinct Guid) as member_count
from Member_RA_Surveys3
where Guid not in (select distinct Guid from Member_wba_surveys3)
;
quit;

*THIS CREATES A TABLE OF THESE 40,079 MEMBERS ABOVE;
proc sql;
create table Member_RA_Surveys4 as
select distinct Guid
from Member_RA_Surveys3
where Guid not in (select distinct Guid from Member_wba_surveys3)
;
quit;


*103,925 DISTINCT SHBP MEMBERS WHO HAVE JUST ONE DOCUMENTED SURVEY IN COMBINED WBA-RA SURVEY DATA FOR 2018 OR BEFORE;
proc sql;
create table SHBP_members_one_survey as
select distinct Guid
from Member_wba_surveys3
where Guid not in (select distinct Guid from Member_RA_Surveys3)
UNION 
select distinct Guid
from Member_RA_Surveys3
where Guid not in (select distinct Guid from Member_wba_surveys3)
;
quit;


