SELECT    p.QCINST_ID
         ,p.QCSID
         ,p.QCSERIAL#
         ,s.USERNAME
         ,s.SQL_ID
         ,s.STATUS
         ,s.EVENT
         ,s.SERVICE_NAME
FROM      GV$SESSION s, GV$PX_SESSION p
WHERE     s.INST_ID                = p.INST_ID
AND       s.SID                    = p.SID
AND       s.SERIAL#                = p.SERIAL#
and       p.qcinst_id = 2
and       p.qcsid     = 4901
and       p.qcserial# = 9403
/
