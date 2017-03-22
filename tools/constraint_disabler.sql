select distinct 'alter table ' || con.table_name || ' disable constraint ' || con.constraint_name  ||';'
from dba_constraints con, dba_cons_columns col
where col.table_name IN ('TRADE', 'LEG')
and   con.constraint_type = 'R'
and   con.r_constraint_name = col.constraint_name
and   con.r_owner = col.owner
/
