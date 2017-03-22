DECLARE
  --Author: Joel Santiago
  --
  --based on http://asktom.oracle.com/pls/asktom/f?p=100:11:7725330506142359::::P11_QUESTION_ID:767025833873
  --adapted for oracle 10g(with SQL_ID, SQL_HASH_VALUE, PLSQL_ENTRY columns already on v$session)
  --
  --v0.9 - initial version, this sort of copies check_all_acive_sessions script output but the input used is DBA_HIST_ACTIVE_SESS_HISTORY

  v_DATE            DATE := TO_DATE('&MY_DATE', 'MM/DD/YYYY HH24:MI');

  v_START_TIME      DATE := CAST((v_DATE - 5 / 24 / 60) as TIMESTAMP);
  v_END_TIME        DATE := CAST((v_DATE + 5 / 24 / 60) as TIMESTAMP);

  v_SNAP_ID         DBA_HIST_SNAPSHOT.SNAP_ID%TYPE;

  v_OWNER           ALL_PROCEDURES.OWNER%TYPE;
  v_OBJECT_NAME     ALL_PROCEDURES.OBJECT_NAME%TYPE;
  v_PROCEDURE_NAME  ALL_PROCEDURES.PROCEDURE_NAME%TYPE;

  v_SQL_ID          V$SESSION.SQL_ID%TYPE;
  v_SQL_HASH_VALUE  V$SESSION.SQL_HASH_VALUE%TYPE;
  b_BLOCKER_FOUND   BOOLEAN := FALSE;

BEGIN

  SELECT SNAP_ID
  INTO   v_SNAP_ID
  FROM   DBA_HIST_SNAPSHOT
  WHERE  CAST(v_DATE AS TIMESTAMP) BETWEEN BEGIN_INTERVAL_TIME AND END_INTERVAL_TIME
  AND ROWNUM = 1;

  DBMS_OUTPUT.PUT_LINE('Using SNAP_ID ' || v_SNAP_ID);


  FOR c_SESSION IN (WITH iv AS(SELECT    INSTANCE_NUMBER
                                        ,SESSION_ID
                                        ,SESSION_SERIAL#
                                        ,USER_ID
                                        ,SAMPLE_TIME
                                        ,SQL_ID
                                        ,SQL_PLAN_HASH_VALUE
                                        ,PLSQL_ENTRY_OBJECT_ID
                                        ,PLSQL_ENTRY_SUBPROGRAM_ID
                                        ,MODULE
                                        ,ACTION
                                        ,TIME_WAITED
                                        ,EVENT
                                        ,SERVICE_HASH
                                        ,BLOCKING_SESSION_SERIAL#
                                        ,BLOCKING_SESSION
                                        ,QC_SESSION_ID
                                        ,QC_INSTANCE_ID
                                        ,CURRENT_OBJ#
                               FROM      DBA_HIST_ACTIVE_SESS_HISTORY
                               WHERE     SAMPLE_TIME    >= v_START_TIME
                               AND       SAMPLE_TIME    <= v_END_TIME
                               AND       SNAP_ID = v_SNAP_ID)
                    SELECT    s.INSTANCE_NUMBER INST_ID
                             ,s.SESSION_ID      SID
                             ,s.SESSION_SERIAL# SERIAL#
                             ,u.USERNAME
                             ,s.SAMPLE_TIME
                             ,s.SQL_ID
                             ,s.SQL_PLAN_HASH_VALUE SQL_HASH_VALUE
                             ,s.PLSQL_ENTRY_OBJECT_ID
                             ,s.PLSQL_ENTRY_SUBPROGRAM_ID
                             --,s.OSUSER
                             ,s.MODULE
                             ,s.ACTION
                             ,s.TIME_WAITED
                             ,s.EVENT
                             ,se.NAME SERVICE_NAME
                             ,s.BLOCKING_SESSION_SERIAL#
                             ,s.BLOCKING_SESSION
                             ,o.OBJECT_NAME
                             ,o.OBJECT_TYPE
                             ,s.QC_SESSION_ID
                             ,s.QC_INSTANCE_ID
                    FROM      iv                           s
                             ,DBA_USERS                    u
                             ,DBA_SERVICES                 se
                             ,DBA_OBJECTS                  o
                    WHERE     u.USERNAME              IS NOT NULL
                    AND       s.USER_ID       = u.USER_ID
                    AND       s.SERVICE_HASH  = se.NAME_HASH
                    AND       s.CURRENT_OBJ#  = o.OBJECT_ID
                    ORDER BY  SAMPLE_TIME, QC_INSTANCE_ID, QC_SESSION_ID, DECODE(s.QC_SESSION_ID, s.SESSION_ID, 1, 2), INST_ID, SID)
  LOOP

    DBMS_OUTPUT.PUT_LINE(  '--------------------------------------------' );
    DBMS_OUTPUT.PUT_LINE(  c_SESSION.USERNAME||' node ' || c_SESSION.INST_ID || '('||c_SESSION.SID||','||c_SESSION.SERIAL#||')');

    IF c_SESSION.QC_SESSION_ID IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE(  'PARENT :' || ' node ' || c_SESSION.QC_INSTANCE_ID || '('||c_SESSION.QC_SESSION_ID||','||'?'||')');
    END IF;

    DBMS_OUTPUT.PUT_LINE(  'Sample Time     : ' || TO_CHAR(c_SESSION.SAMPLE_TIME,'MM/DD/YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE(  'Module          : ' || c_SESSION.MODULE || '  Action: ' || c_SESSION.ACTION);
    --DBMS_OUTPUT.PUT_LINE(  'OS User         : ' || c_SESSION.OSUSER || '(' || TO_CHAR(c_SESSION.PROCESS) || ')');
    DBMS_OUTPUT.PUT_LINE(  'Service         : ' || c_SESSION.SERVICE_NAME );
    DBMS_OUTPUT.PUT_LINE(  'Event           : ' || c_SESSION.EVENT);
    --DBMS_OUTPUT.PUT_LINE(  'Logon Time      : ' || TO_CHAR(c_SESSION.LOGON_TIME,'MM/DD/YYYY HH24:MI') || '  CURRENT  : ' || TO_CHAR(SYSDATE, 'MM/DD/YYYY HH24:MI'));
    DBMS_OUTPUT.PUT_LINE(  'Time Waited      : ' || ROUND(c_SESSION.TIME_WAITED / 60 / 60, 2) || ' hours');

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

    END IF;

    IF v_SQL_ID IS NOT NULL THEN

      FOR C_SQL IN (SELECT SUBSTR(SQL_TEXT, 1, 512) SQL_TEXT
                    FROM   DBA_HIST_SQLTEXT
                    WHERE  SQL_ID     = v_SQL_ID
                   )
      LOOP
        DBMS_OUTPUT.PUT_LINE(c_SQL.SQL_TEXT);
      END LOOP;
    END IF;

    IF c_SESSION.BLOCKING_SESSION IS NOT NULL OR c_SESSION.BLOCKING_SESSION_SERIAL# IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Blocked by node ?(' || c_SESSION.BLOCKING_SESSION || ',' || c_SESSION.BLOCKING_SESSION_SERIAL# || ')');
    END IF;

  END LOOP;

END;
/
