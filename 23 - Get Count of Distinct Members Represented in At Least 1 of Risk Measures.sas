
*GETTING A COUNT OF DISTINCT MEMBERS, (WITH AT LEAST 1 MONTH ELIG IN 2018 YEAR), WHO ARE
REPRESENTED IN AT LEAST 1 OF THE 12 DIFFERENT RISK MEASURES IN THIS LEGACY OUTCOMES ANALYSIS;



**************************************************************************************************************;

*DISTINCT MEMBERS FROM THESE RISKS INITIALLY COMBINED, SINCE THE 'GUID' IS IN CHARACTER FORMAT;

*119,125 DISTINCT MEMBERS HERE;
proc sql;
create table shbp_results_member_count_temp1 as
select distinct guid from shbp_bh.Alc_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Activity_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Illness_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Stress_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Meds_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Life_working_risk3_dq_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Smoke_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Percept_working_risk3_update where elig_months_2018 ge 1
;
quit;


*I AM JUST CREATING THE SAME 'GUID' IDENTIFICAITON VARIABLE IN DIFFERENT FORMAT 
AND MAKING SURE LEADING/TRAILING BLANKS ARE CUT OUT;
Data shbp_results_member_count_temp1;
set shbp_results_member_count_temp1;

guid_num = input(Guid, 15.);
guid_char2 = compress(Guid);
run;


**************************************************************************************************************;


*THESE ARE THE BIOMETRIC RISKS, THE GUID IS IN NUMERIC FORMAT, SO I PUT THESE TOGETHER FIRST, THEN
I WILL CREATE A 'CHARACTER VARIBLE THAT CAN BE USED TO COMBINE WITH THE PERVIOUS 8 RISKS';

*87,879 DISTINCT MEMBERS HERE;
proc sql;
create table shbp_results_member_count_temp2 as
select distinct guid from shbp_bh.Bp_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Bmi_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Hdl_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Totalchol_working_risk3_update where elig_months_2018 ge 1
;
quit;


Data shbp_results_member_count_temp2;
set shbp_results_member_count_temp2;

guid_char = (put(guid, 10.));
guid_char2 = compress(put(guid, 10.));
run;

*******************************************************************************************************************

*COMBINING THE 2 FILES TO GET A DISTINCT LIST OF MEMBERS IN ALL 12 RISKS IN THE ANALYSIS;

*THIS SHOWS 127,378 DISTINCT MEMBERS IN A FINAL LIST - HAVING RESULTS IN AT LEAST ONE OF THE RISK MEASURES;
proc sql;
create table shbp_results_member_list_final as
select distinct guid_num as guid from shbp_results_member_count_temp1b
UNION
select distinct guid from shbp_results_member_count_temp2
order by guid
;
quit;

*******************************************************************************************************************;

*THIS SHOWS THE SAME 127,378 DISTINCT MEMBERS IN A FINAL LIST (AS SHOWN ABOVE);
*JUST USING THE 'CHARACTER' VARIABLE OF GUID TO COMBINE LISTS;

proc sql;
create table shbp_member_list_final_check as
select distinct guid_char2 from shbp_results_member_count_temp1b
UNION
select distinct guid_char2 from shbp_results_member_count_temp2
order by guid_char2
;
quit;



*******************************************************************************************************************;
*******************************************************************************************************************;
*******************************************************************************************************************;


*THIS INITIAL CODE WOULD NOT WORK, SINCE 8 RISK MEASURES DATA HAVE A 'GUID' IN CHARACTER FORMAT,
AND THE 4 BIOMETRIC MEASURES HAVE 'GUID' IN A NUMERIC FORMAT;

proc sql;
create table shbp_results_member_count as
select distinct guid from shbp_bh.Alc_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Activity_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Illness_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Stress_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Meds_working_risk3_update2 where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Bp_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Bmi_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Life_working_risk3_dq_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Smoke_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Percept_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Hdl_working_risk3_update where elig_months_2018 ge 1
UNION 
select distinct guid from shbp_bh.Totalchol_working_risk3_update where elig_months_2018 ge 1
;
quit;


