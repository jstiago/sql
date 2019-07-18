begin
    for i in 1..100 
    loop
        for rec IN (select inst_id, sid, serial#
                          ,osuser
                          ,program
                          ,'begin sys.my_sessions.kill(' || sid || ',' || serial# 
                                                        || ',' || inst_id || '); end;'  KILL_CMD
                    from gv$session
                    where username = 'GS_GC'
                    and   osuser not in ('TrivediZ')
                    and   program like 'SQL%')
        loop
            EXECUTE IMMEDIATE rec.kill_cmd;
        end loop;
        
        DBMS_LOCK.sleep(300);
    end loop;    
end;
/
