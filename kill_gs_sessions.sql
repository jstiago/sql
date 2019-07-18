SET SERVEROUTPUT ON
SET FEEDBACK OFF
WHENEVER SQLERROR EXIT FAILURE
declare
    v_found BOOLEAN := FALSE;
begin
    for rec IN (select username, inst_id, sid, serial#
                      ,osuser
                      ,program
                      ,'begin sys.my_sessions.kill(' || sid || ',' || serial#
                                                    || ',' || inst_id || '); end;'  KILL_CMD
                from gv$session
                where username IN ('GS_GC', 'GS_VD', 'GS_GC_IR', 'GS_GC_APP', 'GS_VD_APP', 'GS_GC_IR_APP')
                and   osuser not in ('jbossadm', 'tom_exec', 'oracle')
                and   program not in ('JDBC Thin Client'))
    loop
            EXECUTE IMMEDIATE rec.kill_cmd;
            DBMS_OUTPUT.PUT_LINE(rec.username || ' : ' || RPAD(rec.osuser, 20) || ' : ' || RPAD(rec.program, 20 ) );
                                 --|| ' : ' || rec.kill_cmd);
            v_found := TRUE;
    end loop;
    IF v_found THEN
        RAISE_APPLICATION_ERROR(-20001, 'Unauthorized Logins found.');
    END IF;
end;
/
