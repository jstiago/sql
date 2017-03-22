select 
n.name statistic, 
v.value statvalue, 
v.statistic# statnum 
from 
v$statname n, 
v$sysstat v 
where 
n.statistic# = v.statistic# and 
 n.name like '%commit%' 
 order by 
 1 asc 
/
