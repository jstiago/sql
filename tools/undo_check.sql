select 
n.name statistic, 
v.value statvalue, 
v.statistic# statnum 
from 
gv$statname n, 
gv$sysstat v 
where n.statistic# = v.statistic# 
and   n.name like '%commit%' 
and   n.inst_id = v.inst_id
order by 
1 asc 
/
select
   r.name roll_name,
   s.osuser || '/' || s.username userID,
   s.sid || '/' || s.serial# usercode,
   s.program program,
   s.status status,
   s.machine machine
from
   v$lock l,
   v$rollname r,
   v$session s
where
   s.sid = l.sid
and 
   trunc(l.id1(+)/65536) = r.usn
and
   l.type(+) = 'TX'
and
   l.lmode(+) = 6
order by 
   r.name
/
select 
   sql.sql_text            sql_text,
   t.used_urec             Records, 
   t.used_ublk             Blocks, 
   (t.used_ublk*8192/2014) Kbytes 
from 
   gv$transaction t, 
   gv$session     s, 
   gv$sql       sql
where 
   t.addr = s.taddr 
and
   t.inst_id = s.inst_id 
and
   s.inst_id = sql.inst_id
and 
   s.sql_id = sql.sql_id
/  