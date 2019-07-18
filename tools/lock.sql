SELECT b.INST_ID
      ,b.SID
      ,b.SERIAL#
      ,a.OBJECT_NAME
      ,b.USERNAME
      ,b.OSUSER
      ,b.STATUS
      ,b.PROGRAM
      ,b.CLIENT_INFO
FROM   ALL_OBJECTS a
      ,SYS.GV_$SESSION b
      ,SYS.GV_$LOCKED_OBJECT c
WHERE  a.OBJECT_ID = c.OBJECT_ID
AND    b.SID = c.SESSION_ID
AND    b.INST_ID = c.INST_ID
--and    c.OBJECT_NAME = 'TRADE_XML'
/
