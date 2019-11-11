

*WORK TO PULL DATA FOR BIOMETRIC RISK MEASURES;


proc freq data=SHBP2.Shbp_lab_14_18;
table TestName;
run;


*355,818 RECORDS;
proc sql;
create table SHBP_TOTAL_CHOL_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'TOT CHOL'
order by calculated DOS
;
quit;

*353,492 RECORDS;
proc sql;
create table SHBP_HDL_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'HDL'
order by calculated DOS
;
quit;


*714,884 RECORDS;
proc sql;
create table SHBP_BP_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'BPDIA'
or TestName = 'BPSYS'
order by calculated DOS
;
quit;



*5,914 RECORDS;
proc sql;
create table SHBP_BMI_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'BMI'
order by calculated DOS
;
quit;

********************************************************************************************************************;

*714,996 RECORDS;
proc sql;
create table SHBP_HT_WT_records as
select distinct GUID, CustomerId, MemberUniqueId, TestName, TestResultValue, UnitOfMeasure,
       input(DateOfService, anydtdte24.) as DOS format=mmddyy10.,
	   year(calculated DOS) as year
from SHBP2.Shbp_lab_14_18
where TestName = 'HEIGHT'
or TestName = 'WEIGHT'
order by calculated DOS
;
quit;



Data SHBP_HT_WT_records2 (keep=GUID DOS TestName TestResultValue);
set SHBP_HT_WT_records;

Guid_num = Guid*1;
run;


proc sort nodupkey data=SHBP_HT_WT_records2 out=SHBP_HT_WT_records2_dedup;
by GUID_num DOS TestName;
run;

*TRANSPOSE TABLE TO GET DATA INTO PROPER FORMAT;
proc transpose data=SHBP_HT_WT_records2_dedup out=SHBP_HT_WT_records2_dedup_trans;
by GUID_num DOS;
id TestName;
var TestResultValue;
run;


*PRODUCE BMI VALUE USING EQUATION;
Data SHBP_HT_WT_records2_dedup_trans2;
set SHBP_HT_WT_records2_dedup_trans;

BMI = (weight/(height*height))*703;

format BMI 4.1;
run;








*EXAMPLE FOR TRYING TO GET THE TRANSPOSE CORRECT;
proc sort data=Ohio_wb5_July18_June19_dedup;
by individual_id contract_name assessment_name complete_date_num;
run;

*TRANSPOSED TABLE OUTPUTTED;
proc transpose data=Ohio_wb5_July18_June19_dedup out=Ohio_wb5_July18_June19_trans;
by individual_id contract_name assessment_name complete_date_num;
    id ASMNT_QUESTION_ID;
    var answertext;
run;

