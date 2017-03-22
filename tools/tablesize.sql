select   segment_name "TABLE_NAME", Sum(bytes) "SIZE(bytes)"
from     dba_segments
where    segment_name = :table_name
group by segment_name
/
