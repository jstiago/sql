select * 
from EMP
AS OF TIMESTAMP SYSDATE – 1
/
select * 
from FEED_PARAMETERS
AS OF TIMESTAMP TO_TIMESTAMP('9-may-2011 12:00', 'dd-mon-yyyy hh24:mi')
/
