
*USING THE NEW SUMMARY TABLE WHERE MEMBERS WITH NO ELIGIBILITY IN 2018 ARE BEING EXCLUDED,
PRODUCE THE NEEDED OUTCOMES FOR USE IN THE 'CHANGE IN RISK' REPORTING TABLE

*ALCOHOL RISK CHANGE - HAS INCREMENTAL CHANGE;

*T1 PERIOD RISK SHOWN;
proc freq data=Alc_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Alc_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Alc_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Alc_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Alc_working_risk3_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Alc_working_risk3_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*****************************************************************************************;

*BLOOD PRESSURE - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Bp_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Bp_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Bp_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bp_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;



*****************************************************************************************;

*BMI - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Bmi_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Bmi_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;

*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Bmi_working_risk3_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*****************************************************************************************;

*HDL CHOLESTEROL - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Hdl_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Hdl_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Hdl_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;

*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Hdl_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;

*****************************************************************************************;

*ILLNESS DAYS - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Illness_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Illness_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Illness_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;



*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Illness_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;


*****************************************************************************************;

*LIFE SATISFACTION - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Life_working_risk3_dq_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;



*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;



*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Life_working_risk3_dq_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;


*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Life_working_risk3_dq_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;

*****************************************************************************************;

*MEDICATION FOR RELAXATION - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Meds_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Meds_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Meds_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Meds_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;

*****************************************************************************************;

*PERCEPTION OF HEALTH - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Percept_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Percept_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;


*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Percept_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Percept_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Percept_working_risk3_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Percept_working_risk3_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;

*****************************************************************************************;

*PHYSICAL ACTIVITY - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Activity_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Activity_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;


*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Activity_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Activity_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;


*****************************************************************************************;

*STRESS - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Stress_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Stress_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;


*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Stress_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;

*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Stress_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;


*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Stress_working_risk3_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Stress_working_risk3_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;

*****************************************************************************************;

*SMOKING - NO INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Smoke_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Smoke_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Smoke_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Smoke_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;


*****************************************************************************************;

*TOTAL CHOLESTEROL - HAS INCREMENTAL;

*T1 PERIOD RISK SHOWN;
proc freq data=Totalchol_working_risk3_update;
table risk_first;
WHERE elig_months_2018 gt 0; 
run;

*RISK IN T1, AND NO RISK T2;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3_update
where risk_first = 1
and risk_last = 0
AND elig_months_2018 gt 0; 
quit;

*NO RISK IN T1, AND HAVE RISK AT T2;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3_update
where risk_first = 0
and risk_last = 1
AND elig_months_2018 gt 0; 
quit;


*GET STARTING RISK, RISK MITIGATED, AND NEW ADOPTED RISK;
proc freq data=Totalchol_working_risk3_update;
table Risk_First*Risk_Last;
WHERE elig_months_2018 gt 0; 
run;



*RISK AT T1 AND T2, RISK HAS IMPROVED;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3_update
where impact1 > 0
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;


*RISK AT T1 AND T2, RISK HAS WORSENED;
proc sql;
select count(distinct Guid)
from Totalchol_working_risk3_update
where impact1 lt 0
and impact1 ne .
and risk_first = 1
and risk_last = 1
AND elig_months_2018 gt 0 
;
quit;
