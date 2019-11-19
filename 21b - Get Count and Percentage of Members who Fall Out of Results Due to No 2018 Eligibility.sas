




*GET COUNTS OF MEMBERS WHO HAVE FALLEN OUT OF THE RISK CHANGE RESULTS DUE TO NO ELIGIBILITY IN 2018;;

/*proc sort data=  */

proc freq data=Alc_working_risk3_update;
table elig_months_2018;
title 'Alcohol Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Bp_working_risk3_update;
table elig_months_2018;
title 'BP Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Bmi_working_risk3_update;
table elig_months_2018;
title 'BMI Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Hdl_working_risk3_update;
table elig_months_2018;
title 'HDL Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Illness_working_risk3_update;
table elig_months_2018;
title 'ILLNESS DAYS Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Life_working_risk3_dq_update;
table elig_months_2018;
title 'LIFE SATISFACTION Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Meds_working_risk3_update;
table elig_months_2018;
title 'MEDICATION FOR RELAX Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Percept_working_risk3_update;
table elig_months_2018;
title 'PERCEPTION of HEALTH Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Activity_working_risk3_update;
table elig_months_2018;
title 'PHYSICAL ACTIVITY Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;



proc freq data=Stress_working_risk3_update;
table elig_months_2018;
title 'STRESS Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


proc freq data=Smoke_working_risk3_update;
table elig_months_2018;
title 'SMOKE Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;



proc freq data=Totalchol_working_risk3_update;
table elig_months_2018;
title 'TOTAL CHOL Risk Behavior - Get Count of Members with 0 2018 Elig Months';
run;


