DECLARE
--set linesize 10000
--spool c:\temp\test_awr_report.html
--
--define  inst_num     = 1;
--define  num_days     = 3;
--define  inst_name    = 'Instance';
--define  db_name      = 'Database';
--define  dbid         = 4;
--define  begin_snap   = 10;
--define  end_snap     = 11;
--define  report_type  = 'text';
--define  report_name  = /tmp/swrf_report_10_11.txt
--@tools/10g/awrrpti

  NO_OPTIONS     CONSTANT NUMBER := 0;
  ENABLE_ADDM    CONSTANT NUMBER := 8;
  v_INSTANCE     DBA_HIST_SNAPSHOT.INSTANCE_NUMBER%TYPE := 1;
  v_DBID         V$DATABASE.DBID%TYPE;
  v_START_DATE   DBA_HIST_SNAPSHOT.END_INTERVAL_TIME%TYPE := TO_DATE('02/10/2011 07:00', 'MM/DD/YYYY HH24:MI');
  v_END_DATE     DBA_HIST_SNAPSHOT.END_INTERVAL_TIME%TYPE := TO_DATE('02/10/2011 09:00', 'MM/DD/YYYY HH24:MI');
  v_START_SNAPID DBA_HIST_SNAPSHOT.SNAP_ID%TYPE;
  v_END_SNAPID   DBA_HIST_SNAPSHOT.SNAP_ID%TYPE;
BEGIN

  SELECT DBID
  INTO   v_DBID
  FROM   V$DATABASE;

  SELECT MIN(SNAP_ID)  , MAX(SNAP_ID)
  INTO   v_START_SNAPID, v_END_SNAPID
  FROM   DBA_HIST_SNAPSHOT
  WHERE  INSTANCE_NUMBER = v_INSTANCE
  AND    END_INTERVAL_TIME BETWEEN v_START_DATE AND v_END_DATE;
  
  DBMS_OUTPUT.PUT_LINE(v_START_SNAPID || ' ' || v_END_SNAPID);

  --FOR rep IN (SELECT OUTPUT
  --            FROM   TABLE(DBMS_WORKLOAD_REPOSITORY.AWR_REPORT_HTML(v_DBID
  --                                                                 ,v_INSTANCE
  --                                                                 ,v_START_SNAPID
  --                                                                 ,v_END_SNAPID
  --                                                                 ,NO_OPTIONS --8 if you want ADDM, otherwise just put 0
  --                                                                  )))
  --LOOP
  --  DBMS_OUTPUT.PUT_LINE(rep.OUTPUT);
  --END LOOP;
END;
/
