col table_name for a30
col partition_name for a30
col subpartition_name for a30
set lines 10000
set pagesize 0
select table_name ||',' || partition_name || ','  || subpartition_name || ',' || num_rows || ',' || sample_size || ',' || last_analyzed || ',' || global_stats || ',' || stale_stats
from user_tab_statistics
order by 1
/
