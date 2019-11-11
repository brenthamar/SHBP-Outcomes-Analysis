
*PAWEL SIMM COSTS FOR RISKS IMPORTED IN, AND THEN REFORMATTED FOR USE WITH EACH OF MEASURES;

proc sort data=Shbp_sim_risk_costs;
by measured_risks year;
run;

proc transpose data=Shbp_sim_risk_costs out=Shbp_sim_costs_trans;
by measured_risks year;
var age_18_34 age_35_44 age_45_54 age_55_64 age_65_;
run;

Data Shbp_sim_costs_trans_final (drop = _NAME_ rename=(_LABEL_ = agegroup COL1=cost));
set Shbp_sim_costs_trans;
run;



