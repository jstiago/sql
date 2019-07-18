SELECT    p.QCSID
         ,p.QCSERIAL#
         ,s.USERNAME
         ,s.SQL_ID
         ,s.STATUS
         ,TO_CHAR(SYSDATE, 'mm/dd/yyyy hh24:mi:ss') CURRENT_TIME
         ,s.MODULE
         ,COUNT(DISTINCT p.SID)               "SESS_COUNT"
FROM      GV$SESSION s, GV$PX_SESSION p
WHERE     s.INST_ID                = p.QCINST_ID
AND       s.SID                    = p.QCSID
AND       s.SERIAL#                = p.QCSERIAL#
GROUP BY  p.QCINST_ID
         ,p.QCSID
         ,p.QCSERIAL#
         ,s.SQL_ID
         ,s.STATUS
         ,s.USERNAME
         ,s.MODULE
ORDER BY  SESS_COUNT DESC
/
