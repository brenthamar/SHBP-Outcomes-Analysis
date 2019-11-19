
*QUESTION COMING UP - WE SHOULD LIMIT MEMBERS BEING USED IN REPORTING SAVINGS, TO MEMBERS WITH ELIG IN 2018 YEAR;


proc means sum data=alc_working_risk3;
var Alc_Impact_Savings Alc_Impact_Savings2 impact1 drinks_T1 drinks_T2;
title 'Final Result for SHBP Alcohol Use Analysis';
run;


proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Alc_Impact_Savings2) as alcohol_savings format=dollar15.2
from alc_working_risk3
;
quit;


*****************************************;

*ALCOHOL - RESULT IS THE SAME;
proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Alc_Impact_Savings2) as alcohol_savings format=dollar15.2
from alc_working_risk3
where guid in (select distinct Guid_char2 from Members_shbp_elig_2018 where total_months_elig_2018 = 12)
;
quit;



*PHYSICAL ACTIVITY - ;
proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Activity_Impact_Savings2) as Activity_savings format=dollar15.2
from Activity_working_risk3
where guid in (select distinct Guid_char2 from Members_shbp_elig_2018 where total_months_elig_2018 = 12)
;
quit;

proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Activity_Impact_Savings2) as Activity_savings format=dollar15.2
from Activity_working_risk3
where guid in (select distinct Guid_char2 from Members_shbp_elig_2018 where total_months_elig_2018 ge 4)
;
quit;


*****************************************;

*ALCOHOL THIS SHOWS THAT ALL MEMBERS HAVE 12 MONTHS ELIG IN 2018;
proc sql;
create table x_alc as
select distinct b.Guid_char2, b.total_months_elig_2018, a.*
from alc_working_risk3 a, Members_shbp_elig_2018 b
where a.Guid = b.Guid_char2
;
quit;


*PHYSICAL ACTIVITY THIS SHOWS THAT ALL MEMBERS HAVE 12 MONTHS ELIG IN 2018;
proc sql;
create table x_activity as
select distinct b.Guid_char2, b.total_months_elig_2018, a.*
from Activity_working_risk3 a, Members_shbp_elig_2018 b
where a.Guid = b.Guid_char2
;
quit;


proc means sum data=x_activity;
var Activity_Impact_Savings Activity_Impact_Savings2;
where total_months_elig_2018 = 0;
format Activity_Impact_Savings2 dollar15.2;
title ' Final Result for SHBP Physical Activity Analysis';
run;


proc sql;
title 'SHBP Alcohol Risk Change Savings Result';
select sum(Activity_Impact_Savings2) as Activity_savings format=dollar15.2
from x_activity
where total_months_elig_2018 ge 1
;
quit;




*****************************************************************;
proc sql;
select count(distinct Guid_char2) as member_count
from Members_shbp_elig_2018
;
quit;

proc sql;
select count(distinct Guid_char2) as member_count
from Members_shbp_elig_2018 
where total_months_elig_2018 ge 1
;
quit;


proc freq data=Activity_first_last_final;
table year_last;
run;

********************************************************************************************************************;
********************************************************************************************************************;
********************************************************************************************************************;
********************************************************************************************************************;

*ANGIE FREEMAN SHARED A NEW 2018 SHBP ELIGIBILITY FILE, I IMPORTED - 'Shbp_elig_2018_angie';


proc freq data=Shbp_elig_2018_angie;
table ORG_UNIT_NAME MONTHS_ELIGIBLE;
title 'Looking at New SHBP 2018 Eligibility Table - from Angie';
run;

*ADD A NEEDED 'GUID' CHARACTER VARIABLE;
proc sql;
create table Shbp_elig_2018_angie2 as
select strip(put(Guid, 15.)) as Guid_char, Guid, max(a.MONTHS_ELIGIBLE) as months_eligible, OrgUnitID, Org_Unit_name,
       datepart(Real_Age_Completion) as Real_Age_Completion_Date format=mmddyy10.
from Shbp_elig_2018_angie a
group by Guid_char, Guid, OrgUnitID, Org_Unit_name, Real_Age_Completion_Date
;
quit;





*ALCOHOL;
proc sql;
create table x_alc2 as
select distinct b.Guid_char, max(b.months_eligible) as months_elig_2018, a.*
from alc_working_risk3 a left join Shbp_elig_2018_angie2 b
on a.Guid = b.Guid_char
order by months_elig_2018
;
quit;



*ALCOHOL;
proc sql;
create table x_alc_test as
select distinct max(b.months_eligible) as months_elig_2018, b.Real_Age_Completion_Date, a.*
from alc_working_risk3 a left join Shbp_elig_2018_angie2 b
on a.Guid = b.Guid_char
order by months_elig_2018
;
quit;



proc sql;
create table x_alc2_check as
select guid, count(*) as rec_count
from x_alc2
group by guid
order by rec_count desc
;
quit;
