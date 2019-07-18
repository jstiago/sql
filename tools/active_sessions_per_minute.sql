with sessiondata as (select snaptime, dbtime / 1000000 dbtime,
  (extract(day from duration) * 86400) +
  (extract(hour from duration) * 3600) +
  (extract(minute from duration) * 60) +
  extract(second from duration) duration
from (
select 
  s.begin_interval_time snaptime, s.begin_interval_time - lag  
 (s.begin_interval_time) over (order by s.begin_interval_time) duration,
  tm.value - lag(tm.value) over (order by s.begin_interval_time) dbtime
from 
   dba_hist_snapshot s, 
   dba_hist_sys_time_model tm
where
   s.snap_id = tm.snap_id
and 
   s.instance_number = tm.instance_number
and 
   s.dbid = tm.dbid
and 
   s.instance_number = (select instance_number from v$instance)
and 
   s.dbid = (select dbid from v$database)
and 
   tm.stat_name = 'DB time'
and 
   --from burleson's site
   --s.snap_id between &beginsnap and &endsnap
   s.begin_interval_time between TO_TIMESTAMP('05/25/2010  12:00', 'MM/DD/YYYY hh24:mi') and TO_TIMESTAMP('05/26/2010  12:00', 'MM/DD/YYYY hh24:mi')
))
select 
   snaptime, 
   duration "Duration (s)", round((dbtime / duration) * 60, 2) "Active Sessions/min"
from 
   sessiondata
/
