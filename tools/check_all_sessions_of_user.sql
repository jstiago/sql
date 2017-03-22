DECLARE
  --Author: Joel Santiago
  --
  --based on http://asktom.oracle.com/pls/asktom/f?p=100:11:7725330506142359::::P11_QUESTION_ID:767025833873
  --adapted for oracle 10g(with SQL_ID, SQL_HASH_VALUE, PLSQL_ENTRY columns already on v$session)
  --
  --parameter: USERNAME

  v_USER DBA_USERS.USERNAME%TYPE := '&USERNAME';

  v_OWNER           ALL_PROCEDURES.OWNER%TYPE;
  v_OBJECT_NAME     ALL_PROCEDURES.OBJECT_NAME%TYPE;
  v_PROCEDURE_NAME  ALL_PROCEDURES.PROCEDURE_NAME%TYPE;

  v_SQL_ID          V$SESSION.SQL_ID%TYPE;
  v_SQL_HASH_VALUE  V$SESSION.SQL_HASH_VALUE%TYPE;
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
                             ,s.MODULE
                             ,s.ACTION
                             ,0             "SLAVE_COUNT"
                             ,s.LAST_CALL_ET
                             ,s.EVENT
                             ,s.SERVICE_NAME
                             ,s.PROCESS
                    FROM      GV$SESSION s
                    WHERE     s.USERNAME               = v_USER
                    AND       (s.INST_ID, s.SID)      NOT IN (SELECT p.INST_ID, p.SID
                                                              FROM   GV$PX_SESSION p)
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
                             ,s.MODULE
                             ,s.ACTION
                             ,COUNT(DISTINCT p.SID) "SLAVE_COUNT"
                             ,s.LAST_CALL_ET
                             ,s.EVENT
                             ,s.SERVICE_NAME
                             ,s.PROCESS
                    FROM      GV$SESSION s, GV$PX_SESSION p
                    WHERE     s.USERNAME               = v_USER
                    --AND       s.STATUS                 = 'ACTIVE' --if it has slaves, then assume it's active even if it is INACTIVE
                    AND       s.INST_ID                = p.QCINST_ID
                    AND       s.SID                    = p.QCSID
                    AND       s.SERIAL#                = p.QCSERIAL#
                    GROUP BY  s.INST_ID
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
                             ,s.MODULE
                             ,s.ACTION
                             ,s.LAST_CALL_ET
                             ,s.EVENT
                             ,s.SERVICE_NAME
                             ,s.PROCESS
                    ORDER BY  LAST_CALL_ET)
  LOOP

    DBMS_OUTPUT.PUT_LINE(  '--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE(  c_SESSION.USERNAME||' node ' || c_SESSION.INST_ID || '('||c_SESSION.SID||','||c_SESSION.SERIAL#||')');

    DBMS_OUTPUT.PUT_LINE(  'Module          : ' || c_SESSION.MODULE || '  Action: ' || c_SESSION.ACTION);
    DBMS_OUTPUT.PUT_LINE(  'OS User         : ' || c_SESSION.OSUSER || '  Machine(process): ' || c_SESSION.MACHINE || '(' || TO_CHAR(c_SESSION.PROCESS) || ')');
    DBMS_OUTPUT.PUT_LINE(  'Service         : ' || c_SESSION.SERVICE_NAME );
    DBMS_OUTPUT.PUT_LINE(  'Event           : ' || c_SESSION.EVENT);
    DBMS_OUTPUT.PUT_LINE(  'Logon Time      : ' || TO_CHAR(c_SESSION.LOGON_TIME,'MM/DD/YYYY HH24:MI') || '  CURRENT  : ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE(  'Connected Time  : ' || ROUND((SYSDATE - c_SESSION.LOGON_TIME) * 24, 2) || ' hours;  ACTIVE FOR      : ' || ROUND(c_SESSION.LAST_CALL_ET / 60 / 60, 2) || ' hours');

    DBMS_OUTPUT.PUT_LINE(  'Parallel Slaves : ' || TO_CHAR(c_SESSION.SLAVE_COUNT));


    IF c_SESSION.SQL_ID IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE(  'SQL ID          : ''' || c_SESSION.SQL_ID || ''', ''' || c_SESSION.SQL_HASH_VALUE || '''');

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
  END LOOP;
END;
/
