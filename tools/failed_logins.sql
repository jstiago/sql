select USERNAME,USERHOST, count(1)
from   DBA_AUDIT_SESSION
where  returncode = 1017
and    timestamp > (sysdate -1/24)
group by username, userhost
order by 3 desc
/

select trunc(cast(timestamp as date), 'hh'), USERNAME,USERHOST, count(1)
from   DBA_AUDIT_SESSION
where  returncode = 1017
group by trunc(cast(timestamp as date), 'hh'), username, userhost
order by 1 asc, 4 desc

