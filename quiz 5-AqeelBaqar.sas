"/folders/myshortcuts/MYFOLDERS";*creating folders for data*;
libname ex "/folders/myshortcuts/MYFOLDERS/Large database/epi5143 work folder/data";
data ex.abstracts; *using the abstracts data*;
set classdat.nhrabstracts; *it's located in classdata*;
run;

data ex.spine; *creating newdataset called spine*;
set ex.abstracts; *extracting the information from the original set*;
where datepart(hraAdmDtm) between '01Jan2003'd and '31Dec2004'd;
keep hraAdmDtm and hraEncWID;
run;

*sql alternative to creating spine dataset*;
proc sql;
create table ex.sqlspine as 
select hraEncWID, hraAdmDtm 
from ex.abstracts
where datepart(hraAdmDtm) between '01Jan2003'd and '31Dec2004'd;
run;

data ex.diagnosis; *we are making a dataset called diagnosis and we are using info from nhrdiagnosis*;
set classdat.nhrdiagnosis;
run;

data ex.diabetes;
set ex.diagnosis;
by hdghraencwid; 
if hdgcd in: ('250','E10','E11') then DM=1;
else DM=0;
run;

proc sort data=ex.diabetes;
by hdghraencwid;
run;

proc transpose data=ex.diabetes out=ex.flat; *flatten dataset*;
by hdgHraEncWID;
var DM;
run;

data ex.flat2;*here, we organize DM*;
set ex.flat;
if col1=1 or col2=1 or col3=1 or col4=1 or col5=1
or col6=1 or col7=1 or col8=1 or col9=1 or col10=1
or col11=1 or col12=1 or col13=1 or col14=1 or col15=1
or col16=1 or col17=1 or col18=1 or col19=1 or col20=1
or col21=1 or col22=1 or col23=1 or col24=1 then DM=1;
else DM=0;
run;

proc sql;
create table ex.linked as 
select s.hraencwid as ID, f.dm
from spine as s 
left join ex.flat2 as f 
on s.hraencwid = f.hdghraencwid;
quit;

data ex.finallink; *This adds value to the missing data of denominator*;
set ex.linked;
if dm=. then dm=0;
run;

proc freq data=ex.finallink; *generating frequency table for DM*;
table DM;
run;


