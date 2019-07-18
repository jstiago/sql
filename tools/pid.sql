SELECT s.sid, s.serial#, s.username, s.client_info, s.module, s.action, s.status, s.event
      ,p.PID     "Oracle PID"
      ,i.HOST_NAME
      ,p.SPID    "BOX PID"
      ,s.PROCESS
FROM   GV$PROCESS  p
      ,GV$SESSION  s
      ,GV$INSTANCE i
WHERE  s.INST_ID = p.INST_ID
AND    s.PADDR   = p.ADDR
AND    s.INST_ID = i.INST_ID
AND    p.spid = '&1'
/
