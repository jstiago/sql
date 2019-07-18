select username, os_username, userhost, extended_timestamp
from   dba_audit_session 
where  returncode= 1017 
order by EXTENDED_TIMESTAMP desc
/
