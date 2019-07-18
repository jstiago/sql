DECLARE
  v_NAME VARCHAR2(50) := '&USER_NAME';
BEGIN
  FOR rec IN (SELECT p.SPID    BOX_PID
                    --,s.INST_ID
                    --,p.PID     "Oracle PID"
                    --,i.HOST_NAME  
                    --,s.PROCESS "Client PID"
                    ,s.SID
                    ,s.SERIAL#
                    ,s.USERNAME
                    ,s.STATUS
                    ,s.ACTION
              FROM   GV$PROCESS  p
                    ,GV$SESSION  s
                    ,GV$INSTANCE i
              WHERE  s.INST_ID = p.INST_ID
              AND    s.PADDR   = p.ADDR
              AND    s.INST_ID = i.INST_ID
              AND    s.USERNAME  = v_NAME)
  LOOP
    PK_TDB_ADMIN.PR_KILL_SESSION(rec.BOX_PID);
    DBMS_OUTPUT.PUT_LINE(rec.USERNAME||'('||rec.SID||','||rec.SERIAL#||') mod[' || v_MODULE || ',' || rec.ACTION || '] - ' || rec.STATUS);
  END LOOP;
END;
/
