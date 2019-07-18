select p.pid, p.spid, s.sid, s.serial#, s.username, s.status
from   v$process p, v$session s
where  s.paddr = p.addr
and    s.username = '&who'
and    s.status = 'KILLED'
/

SELECT s.INST_ID
      ,p.PID     "Oracle PID"
      ,i.HOST_NAME
      ,p.SPID    "BOX PID"
      ,s.PROCESS "Client PID"
      ,s.SID
      ,s.SERIAL#
      ,s.USERNAME
      ,s.STATUS
FROM   GV$PROCESS  p
      ,GV$SESSION  s
      ,GV$INSTANCE i
WHERE  s.INST_ID = p.INST_ID
AND    s.PADDR   = p.ADDR
AND    s.INST_ID = i.INST_ID
AND    s.STATUS  = 'KILLED'
/
