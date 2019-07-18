col child_table for a30
col child_column for a30
col constraint_name for a30
col parent_table for a30
col parent_column for a30
PROMPT ===============================================
PROMPT These are the parents
PROMPT ===============================================
SELECT distinct b.table_name parent_table, b.column_name parent_column, a.table_name child_table, a.column_name child_column, a.constraint_name
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner AND a.constraint_name = c.constraint_name
 join all_cons_columns b on c.owner = b.owner and c.r_constraint_name = b.constraint_name
 WHERE c.constraint_type = 'R'
START WITH a.table_name = '&1'
CONNECT BY NOCYCLE PRIOR b.table_name = a.table_name
/

PROMPT ===============================================
PROMPT These are the children
PROMPT ===============================================
SELECT distinct b.table_name parent_table, b.column_name parent_column, a.table_name child_table, a.column_name child_column, a.constraint_name
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner AND a.constraint_name = c.constraint_name
 join all_cons_columns b on c.owner = b.owner and c.r_constraint_name = b.constraint_name
 WHERE c.constraint_type = 'R'
START WITH a.table_name = '&1'
CONNECT BY NOCYCLE PRIOR a.table_name = b.table_name
/
