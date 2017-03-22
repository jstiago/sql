SELECT    s.INST_ID
         ,s.USERNAME
         ,s.MODULE
         ,s.CLIENT_INFO
         ,s.STATUS
         ,COUNT(1)   "SESS_COUNT"
         ,COUNT(DECODE(p.QCINST_ID, s.SID, 1, NULL, 1)) "MASTER_COUNT"
         ,COUNT(DECODE(p.QCINST_ID, s.SID, NULL, NULL, NULL, 1)) "SLAVE_COUNT"
FROM      GV$SESSION s, GV$PX_SESSION p
WHERE     s.INST_ID                = p.QCINST_ID(+)
AND       s.SID                    = p.QCSID(+)
AND       s.SERIAL#                = p.QCSERIAL#(+)
AND       s.client_info like 'tdb%'
GROUP BY  s.INST_ID
         ,s.USERNAME
         ,s.MODULE
         ,s.CLIENT_INFO
         ,s.STATUS
ORDER BY SESS_COUNT DESC
/
