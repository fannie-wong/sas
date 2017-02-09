libname database xlsx "D:\database.xlsx";
data agents;
set database.agents;
run;
data sales;
set database.properties;
run;
data rates;
set database.rates;
run;
proc sort data=sales;
by id;
run;
data payouts;
merge agents sales rates;
by id;
commission=salesprice*rate;
run;
proc sql;
create table p as 
    select 
	    agents.id,
		name,
		salesprice,
		salesprice*rate as commission
	from agents,sales,rates
where agents.id=sales.id=rates.id;
quit;
proc means data=payouts;
by id;
var commission;
output out=payout_each sum=commission;
run;
proc sql;
create table p_each as
    select
		id,name,
		sum(commission) as commission
	from payouts group by id,name;
quit;
data rates;
set rates;
if end=. then end=year(today());
run;
proc sql;
create table payouts as 
	select 
		agents.id,
		name,
		salesprice,
		salesprice*rate as commission
	from agents,sales,rates
where agents.id=sales.id=rates.id 
	and sales.year between rates.start and rates.end;
quit;
