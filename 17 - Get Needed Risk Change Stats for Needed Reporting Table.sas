
*PRODUCE THE NEEDED OUTCOMES FOR USE IN THE 'CHANGE IN RISK' REPORTING TABLE

*ALCOHOL STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Alc_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Alc_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;

data check1_alc;
set Alc_working_risk3;
if Impact1 < 0 and Impact1 ne .;
run;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Alc_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*BP STATS FOR RESULTS TABLE;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bp_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*BMI STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Bmi_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Bmi_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bmi_working_risk3;
table Risk_First*Risk_Last;
run;


*********************************************************************;

*HDL STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Hdl_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Hdl_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Hdl_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*ILLNESS DAYS STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Illness_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Illness_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Illness_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*LIFE SATISFACTION STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Life_working_risk3_dq
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Life_working_risk3_dq
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Life_working_risk3_dq;
table Risk_First*Risk_Last;
run;


*********************************************************************;

*MEDICATION FOR RELAXATION STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Meds_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Meds_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Meds_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*OVERALL PERCEPTIO0N OF HEALTH STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Percept_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Percept_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Percept_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*PHYSICAL ACTIVITY STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Activity_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Activity_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Activity_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*STRESS STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from STRESS_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from STRESS_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=STRESS_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*SMOKING STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Smoke_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Smoke_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Smoke_working_risk3;
table Risk_First*Risk_Last;
run;

*********************************************************************;

*TOTAL CHOLESTEROL STATS FOR RESULTS TABLE;

*GET COUNT OF MEMBERS WITH RISK IMPROVEMENT;
proc sql;
select count(distinct Guid) as member_count
from Totalchol_working_risk3
where Impact1 > 0
;
quit;

*GET COUNT OF MEMBERS WITH RISK WORSENING;
proc sql;
select count(distinct Guid) as member_count
from Totalchol_working_risk3
where Impact1 < 0
and Impact1 ne .
;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Totalchol_working_risk3;
table Risk_First*Risk_Last;
run;










