col name for a50
col value for a100
col default_value for a100
set pagesize 1000
select name, value, default_value, isdefault
from v$parameter
order by 1
/
