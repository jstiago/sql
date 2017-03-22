DECLARE
  /* This script creates a STATISTICS table to store the statistics, then copies the schema STATS from v_USER */
  v_USER            VARCHAR2(30) := 'TDB'; --'TES'
  v_OWNER           VARCHAR2(30) := 'TDB';
  v_STAT_TAB        VARCHAR2(30) := 'TDB_REFRESH_STATS';
  v_STAT_ID         VARCHAR2(30) := 'DEV11_STATS';
  v_TABLE_NAME      VARCHAR2(30) := '&TABLE_NAME';
BEGIN
  
  DBMS_STATS.EXPORT_TABLE_STATS (
         ownname       => v_OWNER, 
         tabname       => v_TABLE_NAME,
         stattab       => v_STAT_TAB, 
         statid        => v_STAT_ID,
         cascade       => TRUE,
         statown       => v_OWNER);    
    
  COMMIT; --just in case this does not commit ;)
END;
/
