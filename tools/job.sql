DECLARE
  --Author: Joel Santiago
  --
  --based on http://asktom.oracle.com/pls/asktom/f?p=100:11:7725330506142359::::P11_QUESTION_ID:767025833873
  --adapted for oracle 10g(with SQL_ID, SQL_HASH_VALUE, PLSQL_ENTRY columns already on v$session)
  --
  --v1.0 - initial version
  --v1.1 - added listing of parallel slaves with event + blocking session
  --     - added blocker details
  --v1.2 - included PROGRAM in blocker information as it seems useful
  --v1.3 - adding the PID as this is the identifier used in TDB/Oracle to kill sessions
  --v1.4 - fixing the NO_DATA_FOUND error
  --v1.5 - adding the P1, P2, P3 values 
  --v1.6 - adding pga stats
  
  v_CLIENT_INFO     V$SESSION.CLIENT_INFO%TYPE := '&1';
  
  v_OWNER           ALL_PROCEDURES.OWNER%TYPE;
  v_OBJECT_NAME     ALL_PROCEDURES.OBJECT_NAME%TYPE;
  v_PROCEDURE_NAME  ALL_PROCEDURES.PROCEDURE_NAME%TYPE;
  v_SQL_ID          V$SESSION.SQL_ID%TYPE;
  v_SQL_HASH_VALUE  V$SESSION.SQL_HASH_VALUE%TYPE;
  b_BLOCKER_FOUND   BOOLEAN := FALSE;

  v_ORA_PID            V$PROCESS.PID%TYPE; 
  v_BOX_PID            V$PROCESS.SPID%TYPE;
  v_PGA_USED_MEM       V$PROCESS.PGA_USED_MEM%TYPE;
  v_PGA_ALLOC_MEM      V$PROCESS.PGA_ALLOC_MEM%TYPE;   
  v_PGA_FREEABLE_MEM   V$PROCESS.PGA_FREEABLE_MEM%TYPE;
  v_PGA_MAX_MEM        V$PROCESS.PGA_MAX_MEM%TYPE;
  v_SID_SORT_USAGE         V$SORT_USAGE.BLOCKS%TYPE;
  v_SQL_SORT_USAGE         V$SORT_USAGE.BLOCKS%TYPE;
  
  PROCEDURE SHOW_BLOCKER_DETAILS(p_INSTANCE IN NUMBER
                                ,p_SID      IN V$SESSION.SID%TYPE)
  AS
    v_USERNAME ALL_USERS.USERNAME%TYPE;
    v_SERIAL#  V$SESSION.SERIAL#%TYPE;
    v_EVENT    V$SESSION.EVENT%TYPE;
    v_STATUS   V$SESSION.STATUS%TYPE;
    v_PROGRAM  V$SESSION.PROGRAM%TYPE;
  BEGIN
    IF p_INSTANCE IS NOT NULL OR p_SID IS NOT NULL THEN
      BEGIN
        SELECT USERNAME
              ,SERIAL#
              ,EVENT
              ,STATUS
              ,PROGRAM
        INTO   v_USERNAME
              ,v_SERIAL#
              ,v_EVENT
              ,v_STATUS
              ,v_PROGRAM
        FROM   GV$SESSION
        WHERE  INST_ID = p_INSTANCE
        AND    SID     = p_SID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      DBMS_OUTPUT.NEW_LINE;
      DBMS_OUTPUT.PUT_LINE('*** BLOCKER FOUND!!!! ' || NVL(v_USERNAME, '[no name]') || ' node ' || p_INSTANCE || '(' ||p_SID || ',' ||v_SERIAL# || ')');
      DBMS_OUTPUT.PUT_LINE('  ' || v_STATUS || ' - ' || v_EVENT || ' - ' || v_PROGRAM);
      DBMS_OUTPUT.NEW_LINE;
      b_BLOCKER_FOUND := TRUE;
    END IF;
  END SHOW_BLOCKER_DETAILS;
BEGIN
  FOR c_SESSION IN (SELECT    s.INST_ID
                             ,s.SID
                             ,s.SERIAL#
                             ,s.USERNAME
                             ,s.LOGON_TIME
                             ,s.SQL_ID
                             ,s.SQL_HASH_VALUE
                             ,s.PLSQL_ENTRY_OBJECT_ID
                             ,s.PLSQL_ENTRY_SUBPROGRAM_ID
                             ,s.OSUSER
                             ,s.MACHINE
                             ,s.CLIENT_INFO
                             ,s.MODULE
                             ,s.ACTION
                             ,s.LAST_CALL_ET
                             ,s.EVENT
                             ,s.SERVICE_NAME
                             ,s.PROCESS
                             ,s.BLOCKING_INSTANCE
                             ,s.BLOCKING_SESSION
                             ,s.PADDR
                             ,s.SQL_CHILD_NUMBER
                             ,s.P1TEXT
                             ,s.P1
                             ,s.P1RAW
                             ,s.P2TEXT
                             ,s.P2
                             ,s.P2RAW
                             ,s.P3TEXT
                             ,s.P3
                             ,s.P3RAW
                    FROM      GV$SESSION s
                    WHERE     s.CLIENT_INFO like v_CLIENT_INFO     
                    AND       s.STATUS    = 'ACTIVE'                    
                    AND       NOT EXISTS (SELECT 1
                                          FROM   GV$PX_SESSION p
                                          WHERE  p.INST_ID = s.INST_ID
                                          AND    p.SID     = s.SID)
                    UNION ALL
                    SELECT    s.INST_ID
                             ,s.SID
                             ,s.SERIAL#
                             ,s.USERNAME
                             ,s.LOGON_TIME
                             ,s.SQL_ID
                             ,s.SQL_HASH_VALUE
                             ,s.PLSQL_ENTRY_OBJECT_ID
                             ,s.PLSQL_ENTRY_SUBPROGRAM_ID
                             ,s.OSUSER
                             ,s.MACHINE
                             ,s.CLIENT_INFO
                             ,s.MODULE
                             ,s.ACTION
                             ,s.LAST_CALL_ET
                             ,s.EVENT
                             ,s.SERVICE_NAME
                             ,s.PROCESS
                             ,s.BLOCKING_INSTANCE
                             ,s.BLOCKING_SESSION
                             ,s.PADDR
                             ,s.SQL_CHILD_NUMBER
                             ,s.P1TEXT
                             ,s.P1
                             ,s.P1RAW
                             ,s.P2TEXT
                             ,s.P2
                             ,s.P2RAW
                             ,s.P3TEXT
                             ,s.P3
                             ,s.P3RAW
                    FROM      GV$SESSION s
                    WHERE     s.CLIENT_INFO like v_CLIENT_INFO     
                    AND       EXISTS (SELECT 1
                                      FROM   GV$PX_SESSION p
                                      WHERE  s.INST_ID = p.QCINST_ID
                                      AND    s.SID     = p.QCSID)
                    ORDER BY  LAST_CALL_ET)
  LOOP
  
    --MAYBE THIS CAN BE JOINED... BUT NOT SURE YET BECAUSE I NO LONGER HAVE A RAC TO TRY PERFORMANCE
    BEGIN
      SELECT p.PID     ORACLE_PID
            ,p.SPID    BOX_PID
            ,ROUND(p.PGA_USED_MEM     / 1024 / 1024)
            ,ROUND(p.PGA_ALLOC_MEM    / 1024 / 1024)
            ,ROUND(p.PGA_FREEABLE_MEM / 1024 / 1024)
            ,ROUND(p.PGA_MAX_MEM      / 1024 / 1024)
      INTO   v_ORA_PID
            ,v_BOX_PID
            ,v_PGA_USED_MEM    
            ,v_PGA_ALLOC_MEM   
            ,v_PGA_FREEABLE_MEM
            ,v_PGA_MAX_MEM     
      FROM   GV$PROCESS  p
      WHERE  p.INST_ID = c_SESSION.INST_ID
      AND    p.ADDR    = c_SESSION.PADDR;  
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_ORA_PID := NULL;
        v_BOX_PID := NULL;
    END;
    
    SELECT NVL(SUM(DECODE(SESSION_NUM, c_SESSION.SERIAL#, BLOCKS)), 0), NVL(SUM(BLOCKS), 0)
    INTO   v_SID_SORT_USAGE, v_SQL_SORT_USAGE
    FROM   GV$TEMPSEG_USAGE
    WHERE  INST_ID = c_SESSION.INST_ID
    AND    SQL_ID = c_SESSION.SQL_ID;

    DBMS_OUTPUT.PUT_LINE(  '--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE(  c_SESSION.USERNAME||' node ' || c_SESSION.INST_ID || '('||c_SESSION.SID||','||c_SESSION.SERIAL#||')');
    DBMS_OUTPUT.PUT_LINE(  'Oracle PID      : ' || v_ORA_PID || ' PK_TDB_ADMIN.PR_KILL_SESSION(' || v_BOX_PID || ') /* ' || c_SESSION.CLIENT_INFO || ' */');
    DBMS_OUTPUT.PUT_LINE(  'Client Info     : ' || c_SESSION.CLIENT_INFO);
    DBMS_OUTPUT.PUT_LINE(  'Module          : ' || c_SESSION.MODULE || '  Action: ' || c_SESSION.ACTION);
    DBMS_OUTPUT.PUT_LINE(  'OS User         : ' || c_SESSION.OSUSER || '  Machine(process): ' || c_SESSION.MACHINE || '(' || TO_CHAR(c_SESSION.PROCESS) || ')');
    DBMS_OUTPUT.PUT_LINE(  'Service         : ' || c_SESSION.SERVICE_NAME );
    DBMS_OUTPUT.PUT_LINE(  'Event           : ' || c_SESSION.EVENT);
    DBMS_OUTPUT.PUT_LINE(  'Logon Time      : ' || TO_CHAR(c_SESSION.LOGON_TIME,'MM/DD/YYYY HH24:MI') || '  CURRENT  : ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE(  'Connected Time  : ' || ROUND((SYSDATE - c_SESSION.LOGON_TIME) * 24, 2) || ' hours;  ACTIVE FOR      : ' || ROUND(c_SESSION.LAST_CALL_ET / 60 / 60, 2) || ' hours');
    DBMS_OUTPUT.PUT_LINE(  'PGA Memory(MB)  : ' || TO_CHAR(v_PGA_USED_MEM) || ' used; ' || TO_CHAR(v_PGA_ALLOC_MEM) || ' alloc; ' || TO_CHAR(v_PGA_FREEABLE_MEM) || ' freeable');
    DBMS_OUTPUT.PUT_LINE(  'Temp(blocks)    : ' || TO_CHAR(v_SID_SORT_USAGE) || ' sid ; ' || TO_CHAR(v_SQL_SORT_USAGE) || ' sql' );
    --; ' || TO_CHAR(v_PGA_MAX_MEM) || ' max');
    
    IF c_SESSION.EVENT IN ('buffer busy waits'
                          ,'library cache lock'
                          ,'latch: cache buffers chains')
     THEN
      DBMS_OUTPUT.PUT_LINE(  'P1 Info         : ' || c_SESSION.P1TEXT || ' - ' || c_SESSION.P1 || ' - ' || c_SESSION.P1RAW);
      DBMS_OUTPUT.PUT_LINE(  'P2 Info         : ' || c_SESSION.P2TEXT || ' - ' || c_SESSION.P2 || ' - ' || c_SESSION.P2RAW);
      DBMS_OUTPUT.PUT_LINE(  'P3 Info         : ' || c_SESSION.P3TEXT || ' - ' || c_SESSION.P3 || ' - ' || c_SESSION.P3RAW);
    END IF;


    IF c_SESSION.SQL_ID IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE(  'SQL ID          : ''' || c_SESSION.SQL_ID || ''', ''' || c_SESSION.SQL_HASH_VALUE || ''' ~~ ''' || c_SESSION.SQL_ID || ''', ''' || c_SESSION.SQL_CHILD_NUMBER || '''');

      v_SQL_ID         := c_SESSION.SQL_ID;
      v_SQL_HASH_VALUE := c_SESSION.SQL_HASH_VALUE;
    --no SQL ID to display.... get the PL/SQL object... and then try to check on the workarea
    --MOST PROBABLY it's a procedure if it has no SQL_ID
    ELSE
      BEGIN
        SELECT OWNER
              ,OBJECT_NAME
              ,PROCEDURE_NAME
        INTO   v_OWNER
              ,v_OBJECT_NAME
              ,v_PROCEDURE_NAME
        FROM   DBA_PROCEDURES
        WHERE  OBJECT_ID     = c_SESSION.PLSQL_ENTRY_OBJECT_ID
        AND    SUBPROGRAM_ID = c_SESSION.PLSQL_ENTRY_SUBPROGRAM_ID;
        DBMS_OUTPUT.PUT_LINE('Procedure       : ' || v_OWNER || '.' || v_OBJECT_NAME || '.' || v_PROCEDURE_NAME);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           DBMS_OUTPUT.PUT_LINE('unable to determine procedure being executed.');
      END;
      v_OWNER          := NULL;
      v_OBJECT_NAME    := NULL;
      v_PROCEDURE_NAME := NULL;
      --get a record from v$sql_workarea_active
      v_SQL_ID         := NULL;
      v_SQL_HASH_VALUE := NULL;
      BEGIN
        SELECT SQL_ID
              ,SQL_HASH_VALUE
        INTO   v_SQL_ID
              ,v_SQL_HASH_VALUE
        FROM (SELECT SQL_ID
                    ,SQL_HASH_VALUE
              FROM   GV$SQL_WORKAREA_ACTIVE
              WHERE  INST_ID = c_SESSION.INST_ID
              AND    SID     = c_SESSION.SID
              ORDER BY ACTIVE_TIME DESC)
        WHERE ROWNUM < 2;
        DBMS_OUTPUT.PUT_LINE(  'Cursor SQL ID   : ''' || v_SQL_ID || ''', ''' || v_SQL_HASH_VALUE || '''');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;
    IF v_SQL_ID IS NOT NULL THEN
      FOR C_SQL IN (SELECT *
                    FROM  (SELECT SQL_TEXT
                           FROM   GV$SQLTEXT_WITH_NEWLINES
                           WHERE  INST_ID    = c_SESSION.INST_ID
                           AND    SQL_ID     = v_SQL_ID
                           AND    HASH_VALUE = v_SQL_HASH_VALUE
                           AND    PIECE   < 4
                           ORDER BY ADDRESS, PIECE)
                    WHERE  ROWNUM < 10)
      LOOP
        DBMS_OUTPUT.PUT_LINE(c_SQL.SQL_TEXT);
      END LOOP;
    END IF;
    FOR c_PX IN (SELECT    ROWNUM COUNTER
                          ,s.INST_ID
                          ,s.SID
                          ,s.SERIAL#
                          ,s.LAST_CALL_ET
                          ,s.STATUS
                          ,s.EVENT
                          ,s.BLOCKING_INSTANCE
                          ,s.BLOCKING_SESSION
                 FROM      GV$SESSION s, GV$PX_SESSION p
                 WHERE     s.USERNAME              IS NOT NULL
                 --AND       s.STATUS                 = 'ACTIVE' --if it has slaves, then assume it's active even if it is INACTIVE
                 AND       s.INST_ID                = p.INST_ID
                 AND       s.SID                    = p.SID
                 AND       s.SERIAL#                = p.SERIAL#
                 AND       p.QCINST_ID              = c_SESSION.INST_ID
                 AND       p.QCSID                  = c_SESSION.SID
                 AND       p.QCSERIAL#              = c_SESSION.SERIAL#)
    LOOP
      IF c_PX.COUNTER = 1 THEN
        DBMS_OUTPUT.PUT_LINE(  'Parallel Slaves : ');
      END IF;
      DBMS_OUTPUT.PUT_LINE(  '  ' || RPAD(TO_CHAR(c_PX.COUNTER, '900') || ' Node ' || c_PX.INST_ID || '(' || c_PX.SID || ',' || c_PX.SERIAL# || ')', 25) || ' - ' || c_PX.STATUS || ' - ' || c_PX.EVENT);
      --IF c_PX.BLOCKING_INSTANCE IS NOT NULL OR c_PX.BLOCKING_SESSION IS NOT NULL THEN
      --  DBMS_OUTPUT.PUT_LINE(  '  *** BLOCKER FOUND!!!! INST_ID:' || c_PX.BLOCKING_INSTANCE || ' SID:' || c_PX.BLOCKING_SESSION);
      --  b_BLOCKER_FOUND := TRUE;
      --END IF;
      SHOW_BLOCKER_DETAILS(c_PX.BLOCKING_INSTANCE, c_PX.BLOCKING_SESSION);
    END LOOP;
    --IF c_SESSION.BLOCKING_INSTANCE IS NOT NULL OR c_SESSION.BLOCKING_SESSION IS NOT NULL THEN
    --  DBMS_OUTPUT.PUT_LINE(  '*** BLOCKER FOUND!!!! INST_ID:' || c_SESSION.BLOCKING_INSTANCE || ' SID:' || c_SESSION.BLOCKING_SESSION);
    --  b_BLOCKER_FOUND := TRUE;
    --END IF;
    SHOW_BLOCKER_DETAILS(c_SESSION.BLOCKING_INSTANCE, c_SESSION.BLOCKING_SESSION);
  END LOOP;
  IF b_BLOCKER_FOUND THEN
    DBMS_OUTPUT.PUT_LINE(  '*** WARNING - A BLOCKER WAS FOUND. SEE ABOVE LOG ***');
  END IF;
END;
/
