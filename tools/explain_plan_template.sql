select id
,      lpad(' ',2*level)||operation
       ||decode(id,0,' Cost = '||position)
       ||' '||options
       ||' '||object_name as "Query Plan"
from   plan_table
where  statement_id = 'JOEL1'
connect by prior id = parent_id
start with id = 0;


SELECT STATEMENT_ID, SUM(COST) FROM PLAN_TABLE WHERE STATEMENT_ID IN ('JOEL1', 'JOEL2')
GROUP BY STATEMENT_ID							   

DELETE FROM PLAN_TABLE WHERE STATEMENT_ID IN ('JOEL1', 'JOEL2')

COMMIT
							   
explain plan 
SET statement_id = 'JOEL1'
FOR							   
							   
explain plan 
SET statement_id = 'JOEL2'
FOR							   


