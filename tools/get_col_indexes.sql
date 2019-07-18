select column_name, column_position
from dba_ind_columns
where index_name = '&INDEX_NAME'
order by column_position
/
