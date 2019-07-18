DECLARE
  v_DELIMITER  VARCHAR2(1) := ',';
  v_START      TIMESTAMP := TO_TIMESTAMP('10/12/2009', 'MM/DD/YYYY');
  v_END        TIMESTAMP := TO_TIMESTAMP('10/13/2009', 'MM/DD/YYYY');
  v_ACTIVE     NUMBER(5);
  v_OS_LOAD    NUMBER(10, 4);
  v_USER_ID    DBA_USERS.USER_ID%TYPE;

BEGIN

  DBMS_OUTPUT.PUT('SAMPLE_TIME'                               || v_DELIMITER);
  DBMS_OUTPUT.PUT('INST_ID'                                   || v_DELIMITER);
  DBMS_OUTPUT.PUT('MIN_SNAP_ID'                               || v_DELIMITER);
  DBMS_OUTPUT.PUT('MAX_SNAP_ID'                               || v_DELIMITER);
  DBMS_OUTPUT.PUT('USER'                                      || v_DELIMITER);
  DBMS_OUTPUT.PUT('OS_LOAD'                                   || v_DELIMITER);
  DBMS_OUTPUT.PUT('ACTIVE_SESSIONS'                           || v_DELIMITER);
  DBMS_OUTPUT.NEW_LINE;

  <<SNAP_BLOCK>>
  FOR snap IN (SELECT INSTANCE_NUMBER, TRUNC(BEGIN_INTERVAL_TIME, 'hh') SNAP_TIME, MIN(SNAP_ID) MIN_SNAP_ID, MAX(SNAP_ID) MAX_SNAP_ID
               FROM   DBA_HIST_SNAPSHOT
               WHERE  BEGIN_INTERVAL_TIME BETWEEN v_START AND v_END
               GROUP BY TRUNC(BEGIN_INTERVAL_TIME, 'hh'), INSTANCE_NUMBER
               ORDER BY SNAP_TIME, INSTANCE_NUMBER)
  LOOP

    SELECT ROUND(MAX(VALUE), 4)
    INTO   v_OS_LOAD
    FROM   DBA_HIST_OSSTAT
    WHERE  SNAP_ID BETWEEN snap.MIN_SNAP_ID AND snap.MAX_SNAP_ID
    AND    INSTANCE_NUMBER = snap.INSTANCE_NUMBER
    AND    STAT_NAME = 'LOAD';

    DBMS_OUTPUT.PUT(TO_CHAR(snap.SNAP_TIME, 'MM/DD/YYYY HH24:MI')      || v_DELIMITER);
    DBMS_OUTPUT.PUT(snap.INSTANCE_NUMBER                               || v_DELIMITER);
    DBMS_OUTPUT.PUT(snap.MIN_SNAP_ID                                   || v_DELIMITER);
    DBMS_OUTPUT.PUT(snap.MAX_SNAP_ID                                   || v_DELIMITER);
    DBMS_OUTPUT.PUT('ALL USERS'                                        || v_DELIMITER);
    DBMS_OUTPUT.PUT(v_OS_LOAD                                          || v_DELIMITER);
    DBMS_OUTPUT.PUT('N/A'                                              || v_DELIMITER);
    DBMS_OUTPUT.NEW_LINE;

    <<SCHEMA_BLOCK>>
    FOR rec IN (SELECT USERNAME, MAX(SESS_COUNT) SESS_COUNT
                FROM     (SELECT   u.USERNAME, COUNT(1) SESS_COUNT
                          FROM     DBA_HIST_ACTIVE_SESS_HISTORY h
                                  ,DBA_USERS u
                          WHERE    h.SNAP_ID         BETWEEN snap.MIN_SNAP_ID AND snap.MAX_SNAP_ID
                          AND      h.INSTANCE_NUMBER = snap.INSTANCE_NUMBER
                          AND      h.USER_ID         = u.USER_ID
                          GROUP BY u.USERNAME, h.SAMPLE_TIME)
                GROUP BY USERNAME)
    LOOP
      DBMS_OUTPUT.PUT(TO_CHAR(snap.SNAP_TIME, 'MM/DD/YYYY HH24:MI')      || v_DELIMITER);
      DBMS_OUTPUT.PUT(snap.INSTANCE_NUMBER                               || v_DELIMITER);
      DBMS_OUTPUT.PUT(snap.MIN_SNAP_ID                                   || v_DELIMITER);
      DBMS_OUTPUT.PUT(snap.MAX_SNAP_ID                                   || v_DELIMITER);
      DBMS_OUTPUT.PUT(rec.USERNAME                                       || v_DELIMITER);
      DBMS_OUTPUT.PUT('N/A'                                              || v_DELIMITER);
      DBMS_OUTPUT.PUT(rec.SESS_COUNT                                     || v_DELIMITER);
      DBMS_OUTPUT.NEW_LINE;

    END LOOP SCHEMA_BLOCK;
  END LOOP SNAP_BLOCK;

--select inst_id, username, count(1), sum(avg_cpu)
--from (
--select inst_id, username, sid, serial#, max(value), round(max(value) / ((max(datetime) - logon_time) * 24 * 60 * 60 * 100), 4) AVG_CPU
--from   adw_utl.system_resources
--where  trunc(datetime, 'hh') = to_date('10/12/2009 00:00', 'mm/dd/yyyy hh24:mi')
--group by inst_id, username, sid, serial#, logon_time
--)
--group by inst_id, username


END;
/
