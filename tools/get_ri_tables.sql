col table_name for a30
col column_name for a30
col constraint_name for a20

SELECT UCC1.TABLE_NAME
FROM   ALL_CONSTRAINTS UC1, ALL_CONS_COLUMNS UCC1, ALL_CONS_COLUMNS UCC2
WHERE  UCC2.TABLE_NAME = '&1'
AND    UCC2.OWNER = UC1.R_OWNER
AND    UCC2.CONSTRAINT_NAME = UC1.R_CONSTRAINT_NAME
AND    UC1.OWNER = UCC1.OWNER
AND    UC1.CONSTRAINT_NAME = UCC1.CONSTRAINT_NAME
AND    UC1.TABLE_NAME = UCC1.TABLE_NAME
UNION ALL
SELECT UCC2.TABLE_NAME
FROM   ALL_CONSTRAINTS UC1, ALL_CONS_COLUMNS UCC1, ALL_CONS_COLUMNS UCC2
WHERE  UC1.TABLE_NAME = '&1'
AND    UCC2.OWNER = UC1.R_OWNER
AND    UCC2.CONSTRAINT_NAME = UC1.R_CONSTRAINT_NAME
AND    UC1.OWNER = UCC1.OWNER
AND    UC1.CONSTRAINT_NAME = UCC1.CONSTRAINT_NAME
AND    UC1.TABLE_NAME = UCC1.TABLE_NAME
order by 1
/
