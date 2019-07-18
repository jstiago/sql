select 	d.segment_name,
	d.tablespace_name,
       	d.initial_extent/1024 init,
       	d.next_extent/1024 next,
       	d.min_extents,
       	d.max_extents , 
       	v.optsize/1024 opt,
       	v.extents ext,
       	v.rssize/1024 total ,
       	v.status 
from 	sys.dba_rollback_segs d ,
	v$rollstat v
where 	d.segment_id = v.usn
union
select 	d.segment_name,
	d.tablespace_name,
       	d.initial_extent/1024 ,
       	d.next_extent/1024 ,
       	d.min_extents,
       	d.max_extents , 
       	0 ,
       	s.extents ,
       	s.bytes/1024 ,
       	d.status 
from sys.dba_rollback_segs d , sys.dba_segments s
where d.status != 'ONLINE'
  and s.segment_type = 'ROLLBACK'
  and s.segment_name = d.segment_name
order by 1;	  