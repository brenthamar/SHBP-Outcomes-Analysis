
*ALCOHOL RISK CHANGE - HAS INCREMENTAL CHANGE;

*T1 PERIOD RISK SHOWN;
proc freq data=Alc_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Alc_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Alc_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Alc_working_risk3;
table Risk_First*Risk_Last;
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Alc_working_risk3
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Alc_working_risk3
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;


*****************************************************************************************;

*BLOOD PRESSURE - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Bp_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Bp_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Bp_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bp_working_risk3;
table Risk_First*Risk_Last;
run;



*****************************************************************************************;

*BMI - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Bmi_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bmi_working_risk3;
table Risk_First*Risk_Last;
run;

*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;


*****************************************************************************************;

*HDL CHOLESTEROL - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Hdl_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Hdl_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Hdl_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Hdl_working_risk3;
table Risk_First*Risk_Last;
run;

*****************************************************************************************;

*ILLNESS DAYS - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Illness_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Illness_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Illness_working_risk3
where risk_first = 0
and risk_last = 1;
quit;

*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Illness_working_risk3;
table Risk_First*Risk_Last;
run;


*****************************************************************************************;

*LIFE SATISFACTION - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Life_working_risk3_dq;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq
where risk_first = 0
and risk_last = 1;
quit;

*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Life_working_risk3_dq;
table Risk_First*Risk_Last;
run;


*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;

*****************************************************************************************;

*MEDICATION FOR RELAXATION - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Meds_working_risk3_update;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Meds_working_risk3_update
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Meds_working_risk3_update
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Meds_working_risk3;
table Risk_First*Risk_Last;
run;

*****************************************************************************************;

*PERCEPTION OF HEALTH - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Percept_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Percept_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Percept_working_risk3
where risk_first = 0
and risk_last = 1;
quit;

*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Percept_working_risk3;
table Risk_First*Risk_Last;
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Percept_working_risk3
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Percept_working_risk3
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;

*****************************************************************************************;

*PHYSICAL ACTIVITY - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Activity_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Activity_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Activity_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Activity_working_risk3;
table Risk_First*Risk_Last;
run;


*****************************************************************************************;

*STRESS - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Stress_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Stress_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Stress_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=STRESS_working_risk3;
table Risk_First*Risk_Last;
run;


*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Stress_working_risk3
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Stress_working_risk3
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;

*****************************************************************************************;

*SMOKING - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Smoke_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Smoke_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Smoke_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Smoke_working_risk3;
table Risk_First*Risk_Last;
run;


*****************************************************************************************;

*TOTAL CHOLESTEROL - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Totalchol_working_risk3;
table risk_first;
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3
where risk_first = 1
and risk_last = 0;
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3
where risk_first = 0
and risk_last = 1;
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Totalchol_working_risk3;
table Risk_First*Risk_Last;
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3
where impact1 > 0
and risk_first = 1
and risk_last = 1
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
;
quit;
