DECLARE
   h1 NUMBER;
BEGIN
   h1 := DBMS_DATAPUMP.ATTACH('&1','&2');
   DBMS_DATAPUMP.STOP_JOB (h1,1,0);
END;
/
