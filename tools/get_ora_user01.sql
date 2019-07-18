select p.pid, p.spid, s.sid, s.serial#, s.username, s.status
from   v$process p, v$session s
where  s.paddr = p.addr
and    p.spid = &pid
/
