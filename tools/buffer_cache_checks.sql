
select
 s.owner owner,
 object_name objname,
 subobject_name subobjname,
 substr(object_type,1,10) objtype,
 ts.block_size / 1024 blockkb,
 buffer.blocks blocks,
 s.blocks totalblocks,
 (buffer.blocks * ts.block_size / 1024) memkb,
 (buffer.blocks/decode(s.blocks, 0, .001, s.blocks))*100 bufferpercent
from
 (select o.owner, o.object_name, o.subobject_name,
         o.object_type object_type, count(*) blocks
  from dba_objects o, v$bh bh
  where o.object_id = bh.objd and o.owner not in ('SYS','SYSTEM')
  group by o.owner, o.object_name, o.subobject_name, o.object_type) buffer,
  dba_segments s,
 dba_tablespaces ts
where s.tablespace_name = ts.tablespace_name
  and s.owner = buffer.owner
  and s.segment_name = buffer.object_name
  and s.SEGMENT_TYPE = buffer.object_type
  and (s.PARTITION_NAME = buffer.subobject_name or buffer.subobject_name is null)
order by bufferpercent desc;

                                                          
                                                          
SELECT s.username, w.sid, w.event, w.seq#,                
       w.seconds_in_wait, w.wait_time, s.p1 , s.p2, s.p3, 
       s.state, s.p1raw, s.p2raw, s.p3raw                 
   FROM V$SESSION_WAIT w, V$SESSION s                     
WHERE w.SID = s.SID                                       
  AND NOT(w.event like 'SQL%')                            
  AND NOT(w.event like '%message%')                       
  AND NOT(w.event like '%timer%')                         
  AND NOT(w.event like '%pipe get%')                      
  AND NOT(w.event like '%jobq slave wait%')               
  AND NOT(w.event like '%null event%')                    
  AND NOT(w.event like '%wakeup time%')                   
  ORDER BY w.wait_time desc, w.event                      
                                                          
                                                          


Select owner, object_name, tablespace_name, statistic_name, value
From v$segment_statistics
Where OWNER NOT IN ('SYS', 'SYSTEM', 'ORACLE')
AND  statistic_name='buffer busy waits'
ORDER BY VALUE DESC

                                                          
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    