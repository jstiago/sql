select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to ' || grantee || ';'
from   dba_tab_privs
where  grantee = 'TOPATEAM'
and    owner in ('ATGS', 'TOPA');