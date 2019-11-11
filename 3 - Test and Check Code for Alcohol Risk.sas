
***************************************************************************;


Data test1  (keep=guid gender2 drinks_T1 drinks_T2 risk_first risk_last Alcohol_Value_per_Risk Impact_num Impact_denom
                  Impact_Risk Impact_Risk2);
set Alc_working_risk1;

if Risk_First = 1 and Risk_Last = 1;

Alcohol_Value_per_Risk = 86.0;



format Alcohol_Value_per_Risk Dollar10.2;

run;

********************************************************;


Data test2;
set Alc_working_risk3;
if Alc_Impact_Savings lt 0 and Alc_Impact_Savings ne .;
run;


Data test3;
set Alc_working_risk3;

if Year_Last = 2018;
run;

proc freq data=test3;
table Year_First Year_First*Year_Last;
run;


proc sort data=test3;
by Year_First;
run;


proc means sum data=test3;
var Alc_Impact_Savings;
by Year_First;
title 'Sum of Impact Savings by Initial Year of Reading';
title2 'Members with 2018 Record as Last Record';
run;



proc sql;
title 'Alcohol Savings Amount for Recs with 2018 as Last Year, by Initial Year';
select Year_First, count(*) as rec_count, sum(Alc_Impact_Savings) as savings_amount format=DOLLAR10.2
from test3
group by Year_First
;
quit;


*********************************************************************;

proc freq data=Working_risk3;
table value_last*Risk_last;
where gender2 = 'Female';
run;



proc freq data=Alc_working_risk3;
table risk_first;
run;


proc sql;
select count(distinct Guid)
from Alc_working_risk3
where risk_first=1
or risk_last=1
;
quit;
