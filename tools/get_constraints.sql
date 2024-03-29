select DCC.TABLE_NAME, dcc.column_name, dc.constraint_name, dc.search_condition
from   dba_cons_columns dcc, dba_constraints dc
where  dcc.owner = user
and    dcc.table_name = '&1'
and    dcc.owner = dc.owner
and    dcc.constraint_name = DC.CONSTRAINT_NAME
and    dc.constraint_type not in ('P', 'U')
/
