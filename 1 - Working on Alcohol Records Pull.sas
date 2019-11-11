

Data RA_alcohol_temp1;
set SHBP2.Shbp_realage;

where fact_id = 20000;
run;


proc sql;
create table RA_alcohol as
select distinct customer, guid, fact_id, fact_value,
                valid_from_date, valid_to_date, 
                input(valid_from_date, anydtdte24.) as from_date format=mmddyy10.,
				input(valid_to_date, anydtdte24.) as to_date format=mmddyy10.,
				year(calculated from_date) as year_alcohol
from SHBP2.Shbp_realage
where fact_id = 20000 
order by guid, from_date 
;
quit;






Data RA_alcohol_temp2;
set RA_alcohol_temp1;

proc sort;
by guid 


proc freq data=SHBP2.Shbp_realage;
table valid_to_date;
run;
