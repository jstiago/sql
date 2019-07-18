DEFINE FROM_TABLESPACE=&1
DEFINE TO_DATA_TABLESPACE=&2
DEFINE TO_INDEX_TABLESPACE=&3
select distinct 'EXEC ' || owner || '.tablespace_pkg.move_table(''' || rpad(segment_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_segments
where tablespace_name  = '&FROM_TABLESPACE'
and segment_type like 'TABLE%'
union
select distinct 'EXEC ' || owner || '.tablespace_pkg.move_table(''' || rpad(table_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_tables
where tablespace_name  = '&FROM_TABLESPACE'
union all
select distinct 'EXEC ' || owner || '.tablespace_pkg.move_table(''' || rpad(table_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_indexes
where tablespace_name  = '&FROM_TABLESPACE'
union
select distinct 'EXEC ' || owner || '.tablespace_pkg.move_table(''' || rpad(table_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_part_indexes
where def_tablespace_name  = '&FROM_TABLESPACE'
union
select distinct 'EXEC ' || owner || '.tablespace_pkg.move_table(''' || rpad(table_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_part_tables
where def_tablespace_name  = '&FROM_TABLESPACE'
union
select distinct 'EXEC ' || table_owner || '.tablespace_pkg.move_table(''' || rpad(table_name || '''', 32) || ', ''&TO_DATA_TABLESPACE'', ''&TO_INDEX_TABLESPACE'');' --cmd
from dba_lob_partitions
where tablespace_name  = '&FROM_TABLESPACE'
order by 1
/
