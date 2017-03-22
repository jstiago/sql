select column_name
from dba_tab_columns
where table_name = '&TABLE_NAME'
and column_name like '&COLUMN_LIKE'
/
