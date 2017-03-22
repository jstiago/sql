select s.username, s.sid, s.module, s.client_info, s.sql_id, su.segtype, su.blocks, su.extents
from   v$sort_usage su, v$session s
where  s.saddr = su.session_addr
order by su.blocks desc
/
